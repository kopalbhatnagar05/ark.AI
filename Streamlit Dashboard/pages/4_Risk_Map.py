import streamlit as st
import pandas as pd
import numpy as np
import folium
from folium.plugins import MarkerCluster
from streamlit_folium import folium_static
import plotly.express as px
import plotly.graph_objects as go
from constants import FOOTER

# --- Load Data ---
ZONE_STRESS_PATH = "data/zone_stress_index.csv"
SENSOR_DATA_PATH = "data/sensor_anomaly_scored.csv"

# --- Streamlit UI ---
st.set_page_config(
    page_title="Risk Map | Crisis Command Copilot",
    page_icon="🗺️",
    layout="wide"
)

# Sidebar navigation
st.sidebar.title("Navigation")
st.sidebar.markdown("---")

# Main content
st.title("Risk Map")
st.markdown("""
This page displays a geographical map showing the distribution of risks across zones and sensors.
""")

# Load data
zone_df = pd.read_csv(ZONE_STRESS_PATH)
sensor_df = pd.read_csv(SENSOR_DATA_PATH)

# Map options
st.sidebar.subheader("Map Options")
map_type = st.sidebar.selectbox(
    "Select Map Type",
    options=["Folium Map (Original)", "Streamlit Map (Recommended)" ],
    index=0
)
show_sensors = st.sidebar.checkbox("Show Sensors", value=False)
show_zones = st.sidebar.checkbox("Show Zones", value=True)
show_legend = st.sidebar.checkbox("Show Legend", value=True)
show_zone_labels = st.sidebar.checkbox("Show Zone Labels", value=True)

# Filter options
st.sidebar.subheader("Filter Options")
min_stress = st.sidebar.slider("Minimum Zone Stress", 0.0, 1.0, 0.0, 0.1)
filtered_zones = zone_df[zone_df["zone_stress"] >= min_stress]

# Create map
st.subheader("Geographical Risk Distribution")

# --- Helper ---
def score_color(score):
    if score >= 0.8: return "#FF0000"  # Red
    elif score >= 0.5: return "#FFA500"  # Orange
    elif score >= 0.2: return "#FFFF00"  # Yellow
    else: return "#00FF00"  # Green

def zone_color(stress):
    if stress > 0.68: return "#FF0000"  # Red
    elif stress > 0.4: return "#FFA500"  # Orange
    else: return "#00FF00"  # Green

# Display the selected map type
if map_type == "Streamlit Map (Recommended)":
    # Prepare data for the Streamlit map
    map_data = []

    # Add zones if enabled
    if show_zones:
        for _, row in filtered_zones.iterrows():
            zone_sensors = sensor_df[sensor_df["nearest_zone_name"] == row["nearest_zone_name"]]
            if not zone_sensors.empty:
                lat, lon = zone_sensors["latitude"].mean(), zone_sensors["longitude"].mean()
                map_data.append({
                    'lat': lat,
                    'lon': lon,
                    'name': f"Zone {row['nearest_zone_name']}",
                    'stress': row['zone_stress'],
                    'color': zone_color(row['zone_stress']),
                    'size': 15
                })
                
                # Add zone label as a separate point
                if show_zone_labels:
                    # Offset the label slightly to the right of the zone center
                    map_data.append({
                        'lat': lat,
                        'lon': lon + 0.005,  # Small offset to the right
                        'name': f"Zone {row['nearest_zone_name']}",
                        'stress': row['zone_stress'],
                        'color': '#000000',  # Black text
                        'size': 0,  # No circle, just text
                        'text': f"Zone {row['nearest_zone_name']}"  # Text to display
                    })

    # Add sensors if enabled
    if show_sensors:
        for _, row in sensor_df.iterrows():
            map_data.append({
                'lat': row['latitude'],
                'lon': row['longitude'],
                'name': f"Sensor {row['sensor_id']}",
                'score': row['anomaly_score'],
                'color': score_color(row['anomaly_score']),
                'size': 8
            })

    # Convert to DataFrame
    map_df = pd.DataFrame(map_data)

    # Display the Streamlit map
    if not map_df.empty:
        circle_df = map_df[map_df['size'] > 0]
        label_df = map_df[(map_df['size'] == 0) & (map_df['text'].notnull())]
        # Create a map with the data
        # st.map(
        #     map_df,
        #     latitude='lat',
        #     longitude='lon',
        #     size='size',
        #     color='color',
        #     zoom=11,
        #     use_container_width=True
        # )
        fig = px.scatter_mapbox(
            circle_df,
            lat="lat",
            lon="lon",
            color="color",
            size="size",
            hover_name="name",
            zoom=11,
            height=600
        )
        for _, row in label_df.iterrows():
            fig.add_trace(
                go.Scattermapbox(
                    lat=[row['lat']],
                    lon=[row['lon']],
                    mode='text',
                    text=[row['text']],
                    textfont=dict(size=14, color="black", family="Arial Black"),
                    textposition="top right",
                    hoverinfo='skip'
                )
            )
        
        # Add a legend
        st.markdown("""
        **Legend:**
        - **Zones**: 
            - 🔴 High Stress (≥ 0.6)
            - 🟠 Moderate Stress (≥ 0.4)
            - 🟢 Normal Stress (< 0.4)
        - **Sensors**:
            - 🔴 High Anomaly (≥ 0.8)
            - 🟠 Medium Anomaly (≥ 0.5)
            - 🟡 Low Anomaly (≥ 0.2)
            - 🟢 Normal (< 0.2)
        """)
    else:
        st.warning("No data available for the selected filters.")

else:  # Folium Map (Original)
    # Create Folium map
    m = folium.Map(
        location=[sensor_df["latitude"].mean(), sensor_df["longitude"].mean()], 
        zoom_start=12, 
        tiles='cartodbpositron'
    )

    # --- Plot sensors ---
    if show_sensors:
        for _, row in sensor_df.iterrows():
            folium.CircleMarker(
                location=[row["latitude"], row["longitude"]],
                radius=5,
                color=score_color(row["anomaly_score"]),
                fill=True,
                fill_opacity=0.8,
                weight=0.3,
                popup=folium.Popup(f"""
                    <b>ID:</b> {row['sensor_id']}<br>
                    <b>Type:</b> {row.get('sensor_type', 'N/A')}<br>
                    <b>Value:</b> {row['value']}<br>
                    <b>Score:</b> {row['anomaly_score']:.2f}<br>
                    <b>Status:</b> {row['status']}<br>
                    <b>Zone:</b> {row['nearest_zone_name']}<br>
                """, max_width=300)
            ).add_to(m)

    # --- Plot zones ---
    if show_zones:
        for _, row in filtered_zones.iterrows():
            zone_data = sensor_df[sensor_df["nearest_zone_name"] == row["nearest_zone_name"]]
            if not zone_data.empty:
                lat, lon = zone_data["latitude"].mean(), zone_data["longitude"].mean()
                color = "red" if row["zone_stress"] > 0.6 else "orange" if row["zone_stress"] > 0.4 else "green"
                
                # Create the zone circle
                folium.Circle(
                    location=[lat, lon],
                    radius=3000,
                    color=color,
                    fill=True,
                    fill_opacity=0.15,
                    popup=f"Zone {row['nearest_zone_name']} - Stress: {row['zone_stress']:.2f}"
                ).add_to(m)
                
                # Add zone label outside the circle
                # if show_zone_labels:
                #     # Calculate offset to position label outside the circle
                #     # Using a small offset to the northeast of the circle center
                #     label_lat = lat + 0.01
                #     label_lon = lon + 0.01
                    
                #     # Create a label with the zone name
                #     folium.map.Marker(
                #         [label_lat, label_lon],
                #         icon=folium.DivIcon(
                #             html=f'<div style="font-size: 12px; font-weight: bold; color: black; background-color: white; padding: 2px; border-radius: 3px; border: 1px solid {color};">Zone {row["nearest_zone_name"]}</div>'
                #         )
                #     ).add_to(m)
                if show_zone_labels:
                    folium.map.Marker(
                        [lat, lon],
                        icon=folium.DivIcon(
                            html=f'''
                                        <div style="
                                            font-size: 14px;
                                            font-weight: 600;
                                            color: black;
                                            border-radius: 6px;
                                            white-space: nowrap;
                                            text-align: center;
                                            transform: translate(-50%, -50%);
                                        ">
                                    Zone {row["nearest_zone_name"]}
                                </div>
                            '''
                        )
                    ).add_to(m)

    # --- Legend ---
    if show_legend:
        legend_html = '''
         <div style="position: fixed; bottom: 50px; left: 50px; width: 180px; height: 160px; 
         background-color: white; z-index:9999; font-size:14px; border:2px solid grey; border-radius:6px; padding: 10px;">
         <b>Zone Stress Legend</b><br>
         <i style="background:red; width:10px; height:10px; display:inline-block;"></i> High (≥ 0.6)<br>
         <i style="background:orange; width:10px; height:10px; display:inline-block;"></i> Moderate (≥ 0.4)<br>
         <i style="background:green; width:10px; height:10px; display:inline-block;"></i> Normal (< 0.4)
         </div>
        '''
        m.get_root().html.add_child(folium.Element(legend_html))

    # Display map
    folium_static(m)

# Zone stress summary
st.subheader("Zone Stress Summary")
st.dataframe(filtered_zones.sort_values("zone_stress", ascending=False)[["nearest_zone_name", "zone_stress", "avg_anomaly_score", "faulty_rate"]])

# Footer
st.markdown("---")
st.markdown(FOOTER) 

