import requests
import json
import pandas as pd
import time
import sys

class OllamaLLM:
    def __init__(
        self,
        model: str,
        base_url: str = "http://localhost:11434",
        temperature: float = 0,
        stream: bool = False,
        system: str = "You are a helpful graduate teaching assistant",
        max_retries: int = 3,
        retry_delay: float = 1.0
    ):
        """
        Initializes the OllamaLLM adapter.
        """
        self.model = model
        self.base_url = base_url
        self.temperature = temperature
        self.stream = stream
        self.system = system
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        
        # Check if Ollama is running
        self._check_ollama_connection()

    def _check_ollama_connection(self):
        """Check if Ollama server is running and model is available."""
        try:
            # Try to connect to Ollama server
            response = requests.get(f"{self.base_url}/api/tags")
            response.raise_for_status()
            
            # Check if model is available
            models = response.json().get("models", [])
            if not any(m["name"] == self.model for m in models):
                print(f"⚠️ Model '{self.model}' not found. Available models: {[m['name'] for m in models]}")
                print(f"\nTo install the model, run:\n    ollama pull {self.model}")
                sys.exit(1)
                
        except requests.exceptions.ConnectionError:
            print("""
❌ Cannot connect to Ollama server

Please ensure Ollama is installed and running:

1. Install Ollama:
   curl -fsSL https://ollama.com/install.sh | sh

2. Start the server:
   ollama serve

3. Pull the model:
   ollama pull mistral
            """)
            sys.exit(1)
        except Exception as e:
            print(f"❌ Error checking Ollama connection: {str(e)}")
            sys.exit(1)

    def __call__(self, prompt: str) -> str:
        """
        Sends the prompt to the Ollama /api/generate endpoint and returns the generated response.
        """
        url = f"{self.base_url}/api/generate"
        payload = {
            "model": self.model,
            "system": self.system,
            "prompt": prompt,
            "stream": self.stream,
            "options": {"temperature": self.temperature},
        }
        
        for attempt in range(self.max_retries):
            try:
                response = requests.post(url, json=payload)
                response.raise_for_status()
                data = response.json()
                return data.get("response", "")
                
            except requests.exceptions.RequestException as e:
                if attempt == self.max_retries - 1:
                    print(f"❌ Failed to get response after {self.max_retries} attempts: {str(e)}")
                    raise
                print(f"⚠️ Attempt {attempt + 1} failed, retrying in {self.retry_delay}s...")
                time.sleep(self.retry_delay)


def extract_tweet_and_sensor_payload(
    tweet_csv_path: str,
    sensor_csv_path: str,
    cluster_number: int,
    target_timestamp: str = "2023-01-01 00:00:00",
):
    """Extract tweet and sensor data for analysis."""
    try:
        # Load tweets and sensor data
        tweets_df = pd.read_csv(tweet_csv_path)
        sensors_df = pd.read_csv(sensor_csv_path)

        # Convert timestamps
        tweets_df["timestamp"] = pd.to_datetime(tweets_df["timestamp"])
        sensors_df["timestamp"] = pd.to_datetime(sensors_df["timestamp"])

        # Filter tweet row at the given timestamp
        filtered = tweets_df[
            (tweets_df["timestamp"] == target_timestamp)
            & (tweets_df["hdbscan_cluster"] == cluster_number)
        ]

        if filtered.empty:
            raise ValueError(f"No tweet found for timestamp={target_timestamp}, cluster={cluster_number}")

        tweet_row = filtered.iloc[0]

        # Extract tweet in required format
        tweet_payload = {
            "tweet": tweet_row["text"],
            "date time": tweet_row["timestamp"].strftime("%Y-%m-%d %H:%M:%S"),
            "latitude": str(tweet_row["latitude"]),
            "longitude": str(tweet_row["longitude"]),
            "hdbscan_cluster": tweet_row["hdbscan_cluster"],
        }

        # Filter sensors at that timestamp
        sensor_data_at_time = sensors_df[sensors_df["timestamp"] == tweet_row["timestamp"]]

        if sensor_data_at_time.empty:
            print(f"⚠️ No sensor data found for timestamp {tweet_row['timestamp']}")

        # Format sensor data as multi-line CSV string
        sensor_lines = (
            sensor_data_at_time[
                ["timestamp", "latitude", "longitude", "sensor_type", "reading_value"]
            ]
            .astype(str)
            .agg(",".join, axis=1)
            .tolist()
        )

        sensor_csv_block = "\n".join(sensor_lines)
        return tweet_payload, sensor_csv_block

    except FileNotFoundError as e:
        print(f"❌ File not found: {str(e)}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error processing data: {str(e)}")
        sys.exit(1)


def main():
    try:
        # Initialize LLM (this will check Ollama connection)
        llm = OllamaLLM(model="mistral:latest", temperature=0, stream=False)
        
        # Extract data
        tweet_payload, sensor_csv_block = extract_tweet_and_sensor_payload(
            "Smart_City_Dataset/Essential_Data/tweets_with_hdbscan_clusters.csv",
            "Smart_City_Dataset/Essential_Data/sensor_with_clusters_fast.csv",
            cluster_number=89,
            target_timestamp="2023-01-01 00:12:00",
        )
        
        print("📝 Processing tweet:", tweet_payload)
        print("📊 Available sensor data:", sensor_csv_block)

        CRISIS_AGENT_PROMPT = f"""
You are the AI brain of a Smart City, responsible for validating tweets during a multi-disaster crisis using real-time sensor data.

Your task is to decide whether a tweet about a disaster is fake or real based on the following data and rules:

---

TWEET DATA:
- Fields: user_id, text, timestamp, latitude, longitude, hdbscan_cluster

SENSOR DATA:
- Fields: sensor_id, timestamp, latitude, longitude, sensor_type, reading_value, status, assigned_cluster, distance_km_to_cluster

---

EVALUATION RULES:

1. Risk Score Interpretation:
   - Sensor `reading_value` is a risk score from 0 (no risk) to 100 (extreme risk).

2. Disaster-Sensor Mapping:
   - earthquake → seismic
   - fire → fire, air_quality, co2
   - flood → flood
   - heatwave → temperature
   - humidity → humidity

3. Spatiotemporal Matching:
   - Match tweet with sensors within **±10 minutes** and **5 km** distance.
   - Ignore sensors with `status = "faulty"`.

4. Decision Logic:
   - If tweet mentions a disaster but no matching sensor is found within time+location, it's likely fake.
   - If at least one relevant sensor nearby reports risk > 70, it is likely real.
   - Risk > 85 = high confidence. Risk 70–85 = medium confidence. Otherwise = low confidence.

5. Output Format:
Respond with a JSON object:
  - "tweet": The original tweet text
  - "fake": true/false,
  - "confidence": "high/medium/low",
  - "reason": "A short explanation of the verdict using disaster type, sensor type, proximity, and risk score."

---

Be logical and data-driven. If you lack enough evidence, state so clearly.

# Tweet Data
{tweet_payload}

# Sensor Data
{sensor_csv_block}
""".strip()

        # Get LLM response
        result = llm(CRISIS_AGENT_PROMPT)
        print("\n🤖 AI Analysis:", result)
        
        # Parse and return JSON
        return json.loads(result)

    except json.JSONDecodeError:
        print("❌ Error: LLM response is not valid JSON")
        return None
    except Exception as e:
        print(f"❌ Error in main: {str(e)}")
        return None


if __name__ == "__main__":
    res = main()
    if res:
        print("\n📊 Final Analysis:", json.dumps(res, indent=2))
