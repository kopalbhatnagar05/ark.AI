import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import numpy as np
from constants import FOOTER
# --- Load Data ---
ZONE_STRESS_PATH = "data/zone_stress_index.csv"
SENSOR_DATA_PATH = "data/sensor_anomaly_scored.csv"

# --- Streamlit UI ---
st.set_page_config(
    page_title="Data Visualization | Crisis Command Copilot",
    page_icon="📊",
    layout="wide"
)

# Sidebar navigation
st.sidebar.title("Navigation")
st.sidebar.markdown("---")

# Main content
st.title("Data Visualization")

st.markdown("""
This page provides interactive visualizations of zone and sensor data.
""")

# Load data
zone_df = pd.read_csv(ZONE_STRESS_PATH)
sensor_df = pd.read_csv(SENSOR_DATA_PATH)

# Visualization options
viz_type = st.radio(
    "Select Visualization Type",
    ["Parallel Coordinates", "Radar Chart", "Bar Chart", "Scatter Plot"]
)

# Filter high stress zones
high_stress_zones = zone_df[zone_df["zone_stress"] > 0.6]

# Choose zones to visualize
st.subheader("Select Zones to Visualize")
if not high_stress_zones.empty:
    default_zones = high_stress_zones.nlargest(3, "zone_stress")["nearest_zone_name"].tolist()
    selected_zones = st.multiselect(
        "Zones",
        zone_df["nearest_zone_name"].unique(),
        default=default_zones
    )
else:
    selected_zones = st.multiselect(
        "Zones",
        zone_df["nearest_zone_name"].unique(),
        default=zone_df.nlargest(3, "zone_stress")["nearest_zone_name"].tolist()
    )

# Filter data for selected zones
filtered_zone_df = zone_df[zone_df["nearest_zone_name"].isin(selected_zones)]

# Display selected visualization
if viz_type == "Parallel Coordinates":
    st.subheader("Parallel Coordinates Chart")
    
    # Use only selected zones for the parallel coordinates chart
    fig = px.parallel_coordinates(
        filtered_zone_df,
        dimensions=['avg_anomaly_score', 'faulty_rate', 'sensor_count', 'zone_stress'],
        color='nearest_zone_name',
        title="Parallel Coordinates: Zone-wise KPI Profile",
        color_continuous_scale=px.colors.qualitative.Bold  # More vibrant color scale
    )
    
    # Update layout for better visibility
    fig.update_layout(
        plot_bgcolor='white',
        paper_bgcolor='white',
        font=dict(size=12),
        margin=dict(l=50, r=50, t=50, b=50)
    )
    
    st.plotly_chart(fig, use_container_width=True)
    
  

elif viz_type == "Radar Chart":
    st.subheader("Radar Chart")
    
    # Prepare data for radar chart - now including sensor_count
    metrics = ['avg_anomaly_score', 'faulty_rate', 'sensor_count', 'zone_stress']
    
    # Create radar chart
    fig = go.Figure()
    
    # Define a vibrant color palette
    colors = ['#FF5733', '#33A1FF', '#33FF57', '#FF33A1', '#A133FF', '#FFD700', '#00CED1']
    
    # Add traces for each selected zone
    for i, zone in enumerate(selected_zones):
        zone_data = zone_df[zone_df['nearest_zone_name'] == zone].iloc[0]
        
        # Prepare values for radar chart
        values = [zone_data[metric] for metric in metrics]
        values.append(values[0])  # Close the polygon
        
        # Create labels for radar chart
        labels = [metric.replace('_', ' ').title() for metric in metrics]
        labels.append(labels[0])  # Close the polygon
        
        # Add trace with vibrant colors
        fig.add_trace(go.Scatterpolar(
            r=values,
            theta=labels,
            fill='toself',
            name=f'Zone {zone}',
            line=dict(color=colors[i % len(colors)], width=2),
            fillcolor=colors[i % len(colors)],
            opacity=0.7
        ))
    
    # Update layout for better visibility
    fig.update_layout(
        polar=dict(
            radialaxis=dict(
                visible=True,
                range=[0, 1],
                tickfont=dict(size=12),
                gridcolor='lightgray'
            ),
            angularaxis=dict(
                tickfont=dict(size=12),
                gridcolor='lightgray'
            ),
            bgcolor='white'
        ),
        title=dict(
            text=f"Zone Stress Metrics for Selected Zones",
            font=dict(size=16, color='black')
        ),
        showlegend=True,
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=1.02,
            xanchor="right",
            x=1,
            font=dict(size=12)
        ),
        paper_bgcolor='white',
        plot_bgcolor='white'
    )
    
    st.plotly_chart(fig, use_container_width=True)
    


elif viz_type == "Bar Chart":
    st.subheader("Bar Chart")
    
    # Choose metric to visualize
    metric = st.selectbox(
        "Select Metric",
        ["avg_anomaly_score", "faulty_rate", "sensor_count", "zone_stress"]
    )
    
    # Create bar chart with improved colors
    fig = px.bar(
        filtered_zone_df,
        x="nearest_zone_name",
        y=metric,
        title=f"{metric.replace('_', ' ').title()} by Zone",
        labels={"nearest_zone_name": "Zone", metric: metric.replace('_', ' ').title()},
        color="nearest_zone_name",
        color_discrete_sequence=px.colors.qualitative.Bold  # More vibrant color scale
    )
    
    # Update layout for better visibility
    fig.update_layout(
        plot_bgcolor='white',
        paper_bgcolor='white',
        font=dict(size=12),
        margin=dict(l=50, r=50, t=50, b=50)
    )
    
    st.plotly_chart(fig, use_container_width=True)

else:  # Scatter Plot
    st.subheader("Scatter Plot")
    
    # Choose metrics for x and y axes
    x_metric = st.selectbox(
        "X-Axis Metric",
        ["avg_anomaly_score", "faulty_rate", "sensor_count", "zone_stress"]
    )
    
    y_metric = st.selectbox(
        "Y-Axis Metric",
        ["avg_anomaly_score", "faulty_rate", "sensor_count", "zone_stress"],
        index=1
    )
    
    # Create scatter plot with improved colors
    fig = px.scatter(
        filtered_zone_df,
        x=x_metric,
        y=y_metric,
        color="nearest_zone_name",
        size="zone_stress",
        title=f"{y_metric.replace('_', ' ').title()} vs {x_metric.replace('_', ' ').title()}",
        labels={
            x_metric: x_metric.replace('_', ' ').title(),
            y_metric: y_metric.replace('_', ' ').title(),
            "nearest_zone_name": "Zone"
        },
        color_discrete_sequence=px.colors.qualitative.Bold  # More vibrant color scale
    )
    
    # Update layout for better visibility
    fig.update_layout(
        plot_bgcolor='white',
        paper_bgcolor='white',
        font=dict(size=12),
        margin=dict(l=50, r=50, t=50, b=50)
    )
    
    st.plotly_chart(fig, use_container_width=True)

# Footer
st.markdown("---")
st.markdown(FOOTER) 