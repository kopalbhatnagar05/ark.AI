import streamlit as st
import pandas as pd
from disaster import DisasterCascadePredictor
from constants import FOOTER
# --- Load Data ---
ZONE_STRESS_PATH = "data/zone_stress_index.csv"
SENSOR_DATA_PATH = "data/sensor_anomaly_scored.csv"
BN_JSON_PATH = "data/cascade-disaster-cpd.json"

# --- Streamlit UI ---
st.set_page_config(
    page_title="Crisis Command Copilot",
    page_icon="",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Sidebar navigation
st.sidebar.title("Navigation")
st.sidebar.markdown("---")

# Main content
st.title("Smart City Crisis Copilot")

st.markdown("""
This AI Copilot detects red alert zones, infers disaster causes, and predicts cascading risks using sensor + Bayesian data.

## Dashboard Overview

Welcome to the Smart City Crisis Copilot dashboard. Use the navigation menu on the left to explore different aspects of the crisis management system:

- **High Alert Zones**: View zones under high stress and their metrics
- **Disaster Analysis**: Analyze disaster types and predict cascading effects
- **Data Visualization**: Explore interactive visualizations of zone data
- **Risk Map**: View the geographical distribution of risks
""")

# Load data for the overview section
zone_df = pd.read_csv(ZONE_STRESS_PATH)
sensor_df = pd.read_csv(SENSOR_DATA_PATH)
predictor = DisasterCascadePredictor(BN_JSON_PATH)

# Display a summary of high alert zones
high_stress_zones = zone_df[zone_df["zone_stress"] > 0.6]
st.subheader("High Alert Zones Summary")
st.write(f"There are currently **{len(high_stress_zones)}** zones under high stress (stress level > 0.6).")

# Display top 3 high stress zones
if not high_stress_zones.empty:
    st.write("Top 3 highest stress zones:")
    top_zones = high_stress_zones.nlargest(3, "zone_stress")
    for _, zone in top_zones.iterrows():
        st.write(f"- Zone **{zone['nearest_zone_name']}**: Stress level {zone['zone_stress']:.2f}")
else:
    st.info("No zones are currently under high stress.")

# Footer
st.markdown("---")
st.markdown(FOOTER)
