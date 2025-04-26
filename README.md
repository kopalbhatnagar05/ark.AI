# ark.AI: Smart City Crisis Analytics & Resilience Kit
<p align="center">
  <img src="ark_AI.png" width="200" height="200" alt="ark.AI Logo"/>
</p>
🏆 **Winner of Visionary Vanguard Award (2nd Place), Aggie Hacks 2025**  
🔗 [Presentation Deck](https://docs.google.com/presentation/d/1xJmRQbjRaKRPh5PnOXXIxPN9oMZI2oBy7DcGkMzwH6Y/edit?usp=sharing) | Walkthrough: 📱 [iOS App] + 🌐 [Streamlit Dashboard](https://drive.google.com/file/d/1o-ZdXJljXJP4hoHn0Bm-ZltdA-eudum_/view?usp=drivesdk)

---

## 🌎 Project Overview

**ark.AI** is an AI-powered Smart City Resilience Kit designed to protect citizens and empower city leaders during crises.

Developed by *Just a Bunch of Hackers*:
- [Kopal Bhatnagar](https://www.linkedin.com/in/kopalbhatnagar/)
- [Rashmila Mitra](https://www.linkedin.com/in/rashmilamitra/)
- [Arjun Lamba](https://www.linkedin.com/in/arjun777lamba/)

Built in just 48 hours at **Aggie Hacks 2025**, ark.AI moves cities from being **reactive** to **proactive** — using AI to **detect early warnings**, **predict disaster chains**, and **guide people to safety**.

---

## 🔥 The Story Behind ark.AI

It began with a spark in Griffith Park.  
No one saw it.  
Minutes later — panic spread faster than help could.

What if cities could *know before the chaos*?  
What if citizens could *trust every alert*?

ark.AI makes this future possible.

---

## 🧑‍💼 Personas We Serve

| Persona | Needs | Solution |
|:--------|:------|:---------|
| 🧑‍💼 **City Leaders (Emergency Directors)** | Real-time situational awareness, trusted social media validation, and disaster prediction | 🖥️ **Streamlit Dashboard** - Visualize high-risk zones, verify incoming information, forecast cascading disasters |
| 👨‍👩‍👧 **Citizens (General Public)** | Verified, location-specific emergency alerts; shelter maps; misinformation protection | 📱 **ark.AI Mobile App** - Personalized alerts, verified shelter locations, high-trust social media updates |

---

## 🚀 Core Features

| Capability | Description |
|:-----------|:------------|
| 🛰️ **Sensor Fusion & Anomaly Detection** | Detect abnormal patterns using Isolation Forest, DBSCAN, and Z-score calculations |
| 📡 **Risk Validation with LLM** | Validate tweets and news using an offline Mistral-7B agent via Ollama |
| 🔥 **Cascading Disaster Prediction** | Forecast domino-effect disasters using Bayesian Networks and CPT models |
| 🗺️ **Geospatial Risk Scoring** | Highlight critical zones on city maps using GeoJSON + spatial clustering |
| 📱 **Citizen Mobile Alerts** | Swift/SwiftUI app delivering location-aware, verified emergency guidance |
| 🖥️ **City Leader Dashboard** | Streamlit dashboard for live monitoring, shelter redirection, and resource planning |

---

## 📊 Datasets Used

- `city_map.geojson` — Smart city infrastructure and facilities
- `social_media_stream.csv` — Tweets and citizen-generated alerts
- `sensor_readings.csv` — IoT sensor network outputs
- `weather_historical.csv` — Past weather anomalies
- `disaster_events.csv` — Historical disaster events
- `energy_consumption.csv` — Power grid strain and outages
- `economic_activity.csv` — Economic impacts of disruptions
- `transportation.csv` — Traffic, evacuation, and congestion data

---

## 🛠️ Tech Stack

| Layer | Technologies |
|:------|:-------------|
| Backend AI & Logic | Python, Scikit-Learn, pgmpy, HDBSCAN, GeoPy, Ollama |
| Web Dashboard | Streamlit, Plotly, Folium |
| Mobile App | Swift, SwiftUI, Firebase, MapKit |
| Geospatial | GeoPandas, Haversine |
| LLM Agent | Locally Hosted Mistral-7B |




