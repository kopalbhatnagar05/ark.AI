import streamlit as st
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from disaster import DisasterCascadePredictor
from constants import FOOTER

# --- Load Data ---
ZONE_STRESS_PATH = "data/zone_stress_index.csv"
SENSOR_DATA_PATH = "data/sensor_anomaly_scored.csv"
BN_JSON_PATH = "data/cascade-disaster-cpd.json"

# --- Streamlit UI ---
st.set_page_config(
    page_title="Disaster Analysis | Crisis Command Copilot",
    page_icon="",
    layout="wide"
)

# Sidebar navigation
st.sidebar.title("Navigation")
st.sidebar.markdown("---")

# Main content
st.title("Disaster Analysis")

st.markdown("""
This page analyzes disaster types in high-stress zones and predicts potential cascading effects.
""")

# Load data
zone_df = pd.read_csv(ZONE_STRESS_PATH)
sensor_df = pd.read_csv(SENSOR_DATA_PATH)
predictor = DisasterCascadePredictor(BN_JSON_PATH)

# Filter high stress zones
high_stress_zones = zone_df[zone_df["zone_stress"] > 0.6]

# Choose a zone to analyze
st.subheader("Select a Zone to Analyze")
zone_choice = st.selectbox("Zone", high_stress_zones["nearest_zone_name"].unique())

# Infer disaster type in zone (based on sensor type)
zone_sensors = sensor_df[sensor_df["nearest_zone_name"] == zone_choice]
most_common_type = zone_sensors["sensor_type"].mode()[0] if "sensor_type" in zone_sensors.columns else "unknown"

sensor_disaster_map = {
    "seismic": "earthquake",
    "temperature": "fire",
    "water_level": "flood",
    "wind_speed": "hurricane",
    "chemical": "industrial accident"
}
disaster_type = sensor_disaster_map.get(most_common_type.lower(), "fire")

st.markdown(f"In Zone **{zone_choice}**, dominant sensor type suggests a **{disaster_type.upper()}** is ongoing.")

# Predict cascading disaster chain
st.subheader("🔗 Cascading Risk Chain Prediction")
with st.spinner("Predicting cascading disasters..."):
    cascade_paths = predictor.predict_cascade(
        initial_disaster=disaster_type, 
        initial_severity="high", 
        cascade_length=3, 
        top_k=3
    )

# Create a better visualization for the scenarios
if cascade_paths:
    # Create a DataFrame for the scenarios
    scenario_data = []
    
    for i, path_info in enumerate(cascade_paths, 1):
        path = path_info["path"]
        probs = path_info["probabilities"]
        cum_prob = path_info["cumulative_probability"]
        
        # Add each step in the path
        for j, (disaster, prob) in enumerate(zip(path, probs)):
            scenario_data.append({
                "Scenario": f"Scenario {i}",
                "Step": j + 1,
                "Disaster": disaster.upper(),
                "Probability": prob * 100,  # Convert to percentage
                "Cumulative Risk": cum_prob * 100  # Convert to percentage
            })
    
    scenario_df = pd.DataFrame(scenario_data)
    
    # Create a color map for disaster types
    disaster_colors = {
        "EARTHQUAKE": "#FF5733",
        "FIRE": "#FFC300",
        "FLOOD": "#3498DB",
        "HURRICANE": "#9B59B6",
        "INDUSTRIAL ACCIDENT": "#E74C3C",
        "POWER OUTAGE": "#2C3E50",
        "INFRASTRUCTURE FAILURE": "#7F8C8D",
        "EVACUATION": "#1ABC9C",
        "COMMUNICATION FAILURE": "#34495E"
    }
    
    # Create a bar chart for the timeline instead of timeline chart
    fig_timeline = px.bar(
        scenario_df,
        x="Step",
        y="Scenario",
        color="Disaster",
        color_discrete_map=disaster_colors,
        title="Cascading Disaster Scenarios Sequence",
        labels={"Step": "Disaster Step", "Scenario": "Scenario", "Disaster": "Disaster Type"},
        hover_data=["Probability", "Cumulative Risk"],
        height=300,
        orientation="h"  # Horizontal bar chart
    )
    
    # Update layout
    fig_timeline.update_layout(
        xaxis_title="Disaster Step",
        yaxis_title="Scenario",
        legend_title="Disaster Type",
        font=dict(size=14, family="Arial Black")
    )
    
    # Display the timeline
    st.plotly_chart(fig_timeline, use_container_width=True)
    
    # Create a bar chart for probabilities with adjusted y-axis
    fig_prob = px.bar(
        scenario_df,
        x="Scenario",
        y="Probability",
        color="Disaster",
        color_discrete_map=disaster_colors,
        title="Disaster Probabilities by Scenario",
        labels={"Probability": "Probability (%)", "Scenario": "Scenario", "Disaster": "Disaster Type"},
        height=300
    )
    
    # Update layout with adjusted y-axis
    fig_prob.update_layout(
        xaxis_title="Scenario",
        yaxis_title="Probability (%)",
        legend_title="Disaster Type",
        font=dict(size=14, family="Arial Black"),
        yaxis=dict(
            range=[0, 100],  # Set y-axis range from 0 to 100%
            ticksuffix="%"   # Add % symbol to y-axis ticks
        )
    )
    
    # Display the probability chart
    st.plotly_chart(fig_prob, use_container_width=True)
    
    # Create a formatted table for the scenarios
    st.subheader("Detailed Scenario Analysis")
    
    # Create a styled DataFrame for display
    display_data = []
    for i, path_info in enumerate(cascade_paths, 1):
        path = path_info["path"]
        probs = path_info["probabilities"]
        cum_prob = path_info["cumulative_probability"]
        
        # Format the path as a string
        path_str = " → ".join([d.upper() for d in path])
        
        # Format the probabilities as a string
        prob_str = " → ".join([f"{p*100:.2f}%" for p in probs])
        
        display_data.append({
            "Scenario": f"Scenario {i}",
            "Disaster Chain": path_str,
            "Probabilities": prob_str,
            "Cumulative Risk": f"{cum_prob*100:.2f}%"
        })
    
    display_df = pd.DataFrame(display_data)
    
    # Apply styling to the DataFrame
    st.dataframe(
        display_df.style.set_properties(**{
            'font-family': 'Arial Black',
            'font-size': '14px',
            'text-align': 'left',
            'padding': '10px'
        }).set_table_styles([
            {'selector': 'th', 'props': [('font-weight', 'bold'), ('background-color', '#f0f2f6'), ('padding', '10px')]},
            {'selector': 'td', 'props': [('padding', '10px')]},
            {'selector': 'tr:nth-of-type(odd)', 'props': [('background-color', '#f9f9f9')]},
            {'selector': 'tr:hover', 'props': [('background-color', '#e6f7ff')]}
        ]),
        use_container_width=True
    )

# Create Sankey diagram for all scenarios
if cascade_paths:
    # Create node labels and colors
    disaster_colors = {
        "earthquake": "#FF5733",
        "fire": "#FFC300",
        "flood": "#3498DB",
        "hurricane": "#9B59B6",
        "industrial accident": "#E74C3C",
        "power outage": "#2C3E50",
        "infrastructure failure": "#7F8C8D",
        "evacuation": "#1ABC9C",
        "communication failure": "#34495E"
    }
    
    # Default color for any disaster not in our map
    default_color = "#95A5A6"
    
    # Debug: Print the cascade paths to understand the structure
    # st.write("Debug - Cascade Paths:")
    # for i, path_info in enumerate(cascade_paths):
    #     st.write(f"Scenario {i+1}: {path_info['path']} with probabilities {path_info['probabilities']}")
    
    # Create a unique identifier for each node in each scenario
    # This ensures we have separate nodes for the same disaster type in different scenarios
    node_labels = []
    node_colors = []
    
    # First, add the initial disaster node (common to all scenarios)
    initial_disaster = cascade_paths[0]["path"][0]
    node_labels.append(initial_disaster.upper())
    node_colors.append(disaster_colors.get(initial_disaster.lower(), default_color))
    
    # Then add nodes for each subsequent disaster in each scenario
    for scenario_idx, path_info in enumerate(cascade_paths):
        path = path_info["path"]
        for i in range(1, len(path)):
            # Add a unique label for each node
            node_labels.append(f"{path[i].upper()} (S{scenario_idx+1})")
            node_colors.append(disaster_colors.get(path[i].lower(), default_color))
    
    # Create source, target, and value arrays for the Sankey diagram
    source = []
    target = []
    value = []
    
    # Create custom tooltips for links
    link_tooltips = []
    
    # Add links for each scenario
    current_node_idx = 1  # Start after the initial disaster node
    
    for scenario_idx, path_info in enumerate(cascade_paths):
        path = path_info["path"]
        probs = path_info["probabilities"]
        
        # Link from initial disaster to first disaster in this scenario
        source.append(0)  # Index of initial disaster
        target.append(current_node_idx)
        prob_value = probs[1] * 100  # Convert to percentage
        value.append(prob_value)
        
        # Add tooltip for this link
        link_tooltips.append(f"Probability of {path[1].upper()} after {path[0].upper()}: {prob_value:.1f}%")
        
        # Add links between subsequent disasters in this scenario
        for i in range(1, len(path) - 1):
            source.append(current_node_idx)
            target.append(current_node_idx + 1)
            prob_value = probs[i + 1] * 100
            value.append(prob_value)
            
            # Add tooltip for this link
            link_tooltips.append(f"Probability of {path[i+1].upper()} after {path[i].upper()}: {prob_value:.1f}%")
            
            current_node_idx += 1
        
        current_node_idx += 1
    
    # Create the Sankey diagram
    fig = go.Figure(data=[go.Sankey(
        node=dict(
            pad=15,
            thickness=20,
            line=dict(color="black", width=0.5),
            label=node_labels,
            color=node_colors
        ),
        link=dict(
            source=source,
            target=target,
            value=value,
            customdata=link_tooltips,
            hovertemplate="%{customdata}<extra></extra>"
        )
    )])
    
    # Update layout
    fig.update_layout(
        title_text=f"All Cascading Disaster Scenarios for Zone {zone_choice}",
        font=dict(size=14, family="Arial Black"),
        height=500
    )
    
    # Display the Sankey diagram
    st.plotly_chart(fig, use_container_width=True)

# Emergency message with enhanced UI
st.markdown("""
<div style="background-color: #ff4b4b; padding: 20px; border-radius: 10px; margin: 20px 0; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
    <h2 style="color: white; margin-top: 0; text-align: center;">🚨 EMERGENCY ALERT MESSAGE 🚨</h2>
</div>
""", unsafe_allow_html=True)

# Get the alert message
alert = predictor.generate_alert_message(
    initial_disaster=disaster_type, 
    initial_severity="high", 
    location=f"Zone {zone_choice}"
)

# Create a shorter, more focused alert message
# Extract unique disasters from all scenarios
unique_disasters = set()
for path_info in cascade_paths:
    unique_disasters.update([d.upper() for d in path_info["path"]])

# Create a concise message
title = f"EMERGENCY ALERT: {disaster_type.upper()} IN ZONE {zone_choice}"
content = f"""
Currently, a {disaster_type.upper()} is occurring in Zone {zone_choice}.

This could potentially lead to: {', '.join(unique_disasters)}.


"""

# Create columns for the alert message
col1, col2, col3 = st.columns([1, 3, 1])

with col2:
    # Display the alert title
    st.markdown(f"""
    <div style="background-color: #ff4b4b; color: white; padding: 15px; border-radius: 10px; margin-bottom: 10px; text-align: center; font-weight: bold; font-size: 24px;">
        {title}
    </div>
    """, unsafe_allow_html=True)
    
    # Display the alert content
    st.markdown(f"""
    <div style="background-color: #fff8f8; border-left: 5px solid #ff4b4b; padding: 15px; border-radius: 0 10px 10px 0; margin-bottom: 20px; font-size: 16px; line-height: 1.6; color: #333333;">
        {content.replace(chr(10), '<br>')}
    </div>
    """, unsafe_allow_html=True)
    
    # Add action buttons
    # st.markdown("""
    # <div style="display: flex; justify-content: center; gap: 20px; margin-top: 20px;">
    #     <button style="background-color: #ff4b4b; color: white; border: none; padding: 10px 20px; border-radius: 5px; font-weight: bold; cursor: pointer;">🚨 SEND ALERT</button>
    #     <button style="background-color: #4CAF50; color: white; border: none; padding: 10px 20px; border-radius: 5px; font-weight: bold; cursor: pointer;">📋 VIEW PROTOCOL</button>
    # </div>
    # """, unsafe_allow_html=True)

# Footer
st.markdown("---")
st.markdown(FOOTER) 