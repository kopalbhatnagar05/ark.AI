# copilot_response.py

from agent import OllamaLLM

def generate_zone_summary(
    zone_name: str,
    disaster_type: str,
    alert_message: str,
    cascade_path: list,
    cumulative_probability: float,
    model_name: str = "mistral:latest"
) -> str:
    """
    Generates an executive-level AI summary of a crisis zone situation.

    Args:
        zone_name (str): The name of the high-risk zone.
        disaster_type (str): The inferred disaster type (e.g. "fire").
        alert_message (str): The alert generated from the cascade model.
        cascade_path (list): The list of disasters in the predicted cascade.
        cumulative_probability (float): The likelihood of the full cascade path.
        model_name (str): Ollama model to use (default is 'mistral:latest').

    Returns:
        str: A descriptive Copilot response.
    """
    llm = OllamaLLM(model=model_name)

    prompt = f"""
You are an advanced AI Copilot deployed in a Smart City Command Center during a multi-disaster emergency scenario. Your role is to synthesize sensor data, Bayesian risk predictions, and historical disaster patterns to provide clear, confident, and actionable insights to human decision-makers.

You have access to:
1. Live sensor readings indicating the type of disaster in the zone.
2. A Bayesian model that predicts the most likely **cascade of secondary disasters** based on past events.
3. A pre-generated emergency alert that summarizes the current situation.

Now, analyze the following situation and generate a **short, executive-level summary** for city officials. Be concise but insightful. Use assertive language. Your goal is to:
- Clearly state what is happening and where
- Identify the predicted chain of events with probabilities
- Highlight the most urgent threat in the chain
- Offer one immediate, tactical recommendation to mitigate risk

---

📍 **Zone Under Investigation:** Zone {zone_name}  
🔥 **Detected Disaster Type:** {disaster_type.upper()}  
📢 **Emergency Alert:**  
{alert_message}

🔗 **Predicted Cascade Path:**  
{" → ".join(cascade_path)}  
🧮 **Cumulative Probability:** {cumulative_probability:.1%}

---

Respond with a confident, human-readable paragraph. End with a one-sentence **Action Tip**.
""".strip()

    return llm(prompt)
