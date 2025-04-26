import streamlit as st
import pandas as pd
import plotly.graph_objects as go
import numpy as np
from constants import FOOTER
# --- Load Data ---
ZONE_STRESS_PATH = "data/zone_stress_index.csv"
SENSOR_DATA_PATH = "data/sensor_anomaly_scored.csv"

# --- Streamlit UI ---
st.set_page_config(
    page_title="High Alert Zones | Crisis Command Copilot",
    page_icon="",
    layout="wide"
)

# Sidebar navigation
st.sidebar.title("Navigation")
st.sidebar.markdown("---")

# Main content
st.title("High Alert Zones")

st.markdown("""
This page displays zones under high stress and provides detailed metrics for each zone.
""")

# Load data
zone_df = pd.read_csv(ZONE_STRESS_PATH)
sensor_df = pd.read_csv(SENSOR_DATA_PATH)

# Filter high stress zones
high_stress_zones = zone_df[zone_df["zone_stress"] > 0.6]

# Display high stress zones table
st.subheader("High Alert Zones Table")
st.dataframe(high_stress_zones.sort_values("zone_stress", ascending=False))

# Create a zone selector
st.subheader("Select Zone to Analyze")
selected_zone = st.selectbox(
    "Choose a zone to view detailed metrics",
    options=zone_df["nearest_zone_name"].unique(),
    index=0 if high_stress_zones.empty else zone_df[zone_df["nearest_zone_name"].isin(high_stress_zones["nearest_zone_name"])].index[0]
)

# Get data for the selected zone
zone_data = zone_df[zone_df["nearest_zone_name"] == selected_zone].iloc[0]

# Display zone metrics
st.subheader(f"Zone Metrics: {selected_zone}")

# Create a color scale based on zone stress
stress_level = zone_data["zone_stress"]
if stress_level < 0.3:
    color = "rgb(0, 128, 255)"  # Blue for low stress
elif stress_level < 0.6:
    color = "rgb(255, 165, 0)"  # Orange for medium stress
else:
    color = "rgb(255, 0, 0)"    # Red for high stress

# Create a styled metrics display
col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        label="Zone Stress",
        value=f"{zone_data['zone_stress']:.2f}",
        delta=None,
        delta_color="normal"
    )

with col2:
    st.metric(
        label="Avg Anomaly Score",
        value=f"{zone_data['avg_anomaly_score']:.2f}",
        delta=None,
        delta_color="normal"
    )

with col3:
    st.metric(
        label="Faulty Rate",
        value=f"{zone_data['faulty_rate']:.2f}%",
        delta=None,
        delta_color="normal"
    )

with col4:
    st.metric(
        label="Sensor Count",
        value=f"{zone_data['sensor_count']}",
        delta=None,
        delta_color="normal"
    )

# Add a brief explanation

# Footer
st.markdown("---")
st.markdown(FOOTER) 