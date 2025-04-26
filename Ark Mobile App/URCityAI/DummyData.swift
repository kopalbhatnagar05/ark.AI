//
//  DummyData.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import Foundation
import CoreLocation

// MARK: - Dummy Emergency Alerts ---------------------------------------------

let dummyAlerts: [EmergencyAlert] = [
    EmergencyAlert(
        title: "Flash Flood Warning",
        description: "Heavy rainfall causing flooding in zone C. Avoid low‑lying areas.",
        severity: .critical,
        coordinate: CLLocationCoordinate2D(latitude: 37.332, longitude: -122.031),
        timeStamp: Date().addingTimeInterval(-1_800),   // 30 min ago
        actionSteps: [
            "Move to higher ground",
            "Avoid walking or driving through flood waters",
            "Follow evacuation orders if issued"
        ]
    ),
    EmergencyAlert(
        title: "Earthquake",
        description: "Minor tremors reported in the area. Magnitude 3.2.",
        severity: .medium,
        coordinate: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.030),
        timeStamp: Date().addingTimeInterval(-3_600),   // 1 hour ago
        actionSteps: [
            "Drop, cover, and hold on",
            "Stay away from windows",
            "Check for gas leaks after shaking stops"
        ]
    ),
    EmergencyAlert(
        title: "Wildfire Alert",
        description: "Fire reported near business district. Smoke may affect air quality.",
        severity: .high,
        coordinate: CLLocationCoordinate2D(latitude: 37.335, longitude: -122.032),
        timeStamp: Date().addingTimeInterval(-7_200),   // 2 hours ago
        actionSteps: [
            "Stay indoors if possible",
            "Keep windows and doors closed",
            "Monitor local news for evacuation orders"
        ]
    )
]

// MARK: - Dummy Tweets --------------------------------------------------------

let dummyTweets: [Tweet] = [
    Tweet(username: "EmergencyUpdates",
          handle: "@emergency_updates",
          content: "ALERT: Flood waters rising in zone C. Stay away from Main St and River Rd. #FloodWarning",
          timestamp: Date().addingTimeInterval(-900),
          verified: true),
    Tweet(username: "WeatherService",
          handle: "@weather_service",
          content: "Heavy rainfall continuing for next 2 hours. Flash flood warning extended until 8 PM. #SafetyFirst",
          timestamp: Date().addingTimeInterval(-1_200),
          verified: true),
    Tweet(username: "CityOfficial",
          handle: "@city_official",
          content: "Zone C evacuation centers now open at Community Center and North High School. Bring essentials only. #FloodResponse",
          timestamp: Date().addingTimeInterval(-1_500),
          verified: true),
    Tweet(username: "TrafficAlert",
          handle: "@traffic_alert",
          content: "ROAD CLOSURE: Highway 101 at River crossing due to flooding. Use alternate routes. #TrafficUpdate",
          timestamp: Date().addingTimeInterval(-1_800),
          verified: true),
    Tweet(username: "LocalReporter",
          handle: "@local_news",
          content: "On the scene at Zone C floods. Water levels rising ~1 inch every 30 min. Stay safe everyone! #LocalNews",
          timestamp: Date().addingTimeInterval(-2_100),
          verified: false)
]

// MARK: - Dummy Facilities ----------------------------------------------------

let dummyFacilities: [Facility] = [
    Facility(
        name: "General Hospital",
        type: "Hospital",
        currentCapacity: 45,
        totalCapacity: 100,
        coordinate: CLLocationCoordinate2D(latitude: 37.331, longitude: -122.030),
        address: "123 Medical Drive",
        contactInfo: "555‑123‑4567",
        services: ["Emergency Care", "Surgery", "Trauma Center"]
    ),
    Facility(
        name: "City Shelter",
        type: "Shelter",
        currentCapacity: 80,
        totalCapacity: 150,
        coordinate: CLLocationCoordinate2D(latitude: 37.333, longitude: -122.029),
        address: "456 Haven Street",
        contactInfo: "555‑987‑6543",
        services: ["Food", "Bedding", "Medical Aid", "Pet Accommodations"]
    ),
    Facility(
        name: "Community Center",
        type: "Shelter",
        currentCapacity: 35,
        totalCapacity: 75,
        coordinate: CLLocationCoordinate2D(latitude: 37.336, longitude: -122.028),
        address: "789 Community Lane",
        contactInfo: "555‑456‑7890",
        services: ["Food", "Bedding", "Child Care"]
    )
]

// MARK: - Dummy Businesses ----------------------------------------------------

let dummyBusinesses: [Business] = [
    Business(
        name: "Joe's Cafe",
        businessType: "Food Service",
        riskLevel: 0.3,
        coordinate: CLLocationCoordinate2D(latitude: 37.332, longitude: -122.031),
        address: "123 Main Street",
        contactInfo: "555‑111‑2222"
    ),
    Business(
        name: "Tech Hub",
        businessType: "Retail",
        riskLevel: 0.6,
        coordinate: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.032),
        address: "456 Innovation Drive",
        contactInfo: "555‑333‑4444"
    ),
    Business(
        name: "Riverside Market",
        businessType: "Grocery",
        riskLevel: 0.8,
        coordinate: CLLocationCoordinate2D(latitude: 37.330, longitude: -122.033),
        address: "789 River Road",
        contactInfo: "555‑555‑6666"
    )
]

// MARK: - Dummy Safety Tips ---------------------------------------------------

let dummySafetyTips: [SafetyTip] = [
    SafetyTip(title: "Flood Safety",
              description: "Never walk or drive through flood waters. Six inches can knock you down; a foot can sweep a vehicle away.",
              iconName: "drop.fill"),
    SafetyTip(title: "Earthquake Preparedness",
              description: "Drop, Cover, and Hold On: take cover under sturdy furniture until shaking stops.",
              iconName: "waveform.path.ecg"),
    SafetyTip(title: "Emergency Kit",
              description: "Have water, non‑perishable food, meds, first‑aid, flashlight, radio in a ready‑to‑grab kit.",
              iconName: "cross.case.fill"),
    SafetyTip(title: "Evacuation Plan",
              description: "Set family meeting points and know multiple evacuation routes from home and work.",
              iconName: "figure.walk.circle")
]

// MARK: - Dummy Resource Contacts --------------------------------------------

let dummyResourceContacts: [ResourceContact] = [
    ResourceContact(name: "Emergency Services",
                    phoneNumber: "911",
                    website: nil,
                    category: "Emergency"),
    ResourceContact(name: "City Emergency Management",
                    phoneNumber: "555‑123‑4567",
                    website: "https://city.gov/emergency",
                    category: "Government"),
    ResourceContact(name: "Red Cross",
                    phoneNumber: "555‑987‑6543",
                    website: "https://redcross.org",
                    category: "Relief"),
    ResourceContact(name: "Power Outage Reporting",
                    phoneNumber: "555‑456‑7890",
                    website: "https://utility.com/outage",
                    category: "Utilities")
]
