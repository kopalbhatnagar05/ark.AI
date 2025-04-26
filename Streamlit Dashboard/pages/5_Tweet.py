# 5_🕵️_Tweet_Validator.py

import streamlit as st
import pandas as pd
import json
from agent import OllamaLLM, extract_tweet_and_sensor_payload
from constants import FOOTER
# --- Page Config ---
st.set_page_config(
    page_title="Tweet Validator | Crisis Command Copilot",
    page_icon="🕵️",
    layout="wide"
)

st.title("🕵️ Tweet Trust Validator")
st.markdown("Analyze the **latest 5 tweets** from a selected zone using real-time sensors + AI.")

# --- Load tweet data ---
@st.cache_data
def load_tweets():
    return pd.read_csv("data/tweets_with_hdbscan_clusters.csv", parse_dates=["timestamp"])

tweets_df = load_tweets()

# --- Select Zone ---
st.subheader("📍 Select a Zone")
zone_options = sorted(tweets_df["hdbscan_cluster"].dropna().unique())
selected_zone = st.selectbox("Choose HDBSCAN Cluster (Zone)", zone_options)

# --- Filter Top 5 Tweets by Time ---
zone_tweets = tweets_df[tweets_df["hdbscan_cluster"] == selected_zone]
top_tweets = zone_tweets.sort_values("timestamp", ascending=False).head(5)

if top_tweets.empty:
    st.warning("No tweets available for this zone.")
else:
    st.subheader("🤖 Agent Analysis of Latest 5 Tweets")
    with st.spinner("Running AI agent on tweets..."):

        llm = OllamaLLM(model="mistral:latest")
        results = []

        for _, row in top_tweets.iterrows():
            timestamp = row["timestamp"].strftime("%Y-%m-%d %H:%M:%S")
            cluster = row["hdbscan_cluster"]

            try:
                tweet_payload, sensor_block = extract_tweet_and_sensor_payload(
                    tweet_csv_path="data/tweets_with_hdbscan_clusters.csv",
                    sensor_csv_path="data/sensor_with_clusters_fast.csv",
                    cluster_number=cluster,
                    target_timestamp=timestamp
                )

                # Build prompt
                prompt = f"""
You are the AI brain of a Smart City, responsible for validating tweets during a multi-disaster crisis using real-time sensor data.

Evaluate the tweet and determine if it's fake or real using these rules:
- Sensor `reading_value` indicates risk from 0–100
- Use sensors within ±10min and 5km and keep the clusters in mind
- Risk > 85 → High Confidence
- Risk 70–85 → Medium
- Else → Low

Respond with JSON:
{{
  "tweet": "...",
  "fake": true/false,
  "confidence": "high/medium/low",
  "reason": "..."
}}

TWEET DATA:
{tweet_payload}

SENSOR DATA:
{sensor_block}
""".strip()

                response = llm(prompt)
                result = json.loads(response)
                results.append(result)

            except Exception as e:
                results.append({
                    "tweet": row["text"],
                    "confidence": "error",
                    "reason": f"Agent failed: {str(e)}"
                })

    # --- Display Results ---
    for i, res in enumerate(results, 1):
        tweet = res.get("tweet", "N/A")
        confidence = res.get("confidence", "error").capitalize()
        reason = res.get("reason", "No explanation available.")

        # Badge color
        badge = {
            "High": "🟩",
            "Medium": "🟨",
            "Low": "🟥",
            "Error": "⚪"
        }.get(confidence, "⚪")

        with st.container():
            st.markdown(f"### Tweet #{i}")
            st.markdown(f"> {tweet}")
            st.markdown(f"**Trust Score:** {badge} {confidence}")
            with st.expander("ℹ️ AI Explanation"):
                st.write(reason)

            st.markdown("---")
st.markdown(FOOTER)
