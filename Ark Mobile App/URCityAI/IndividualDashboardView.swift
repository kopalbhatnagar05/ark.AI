//
//  IndividualDashboardView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI
import CoreLocation
import MapKit

/// Tab‑centric home screen for “Individual” users.
struct IndividualDashboardView: View {
    
    // MARK: - Dependencies & State
    @Binding var selectedRole: UserRole?
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var isLiveLocationEnabled   = false
    @State private var showingNoPermissionAlert = false
    @State private var showShareSheet          = false
    @State private var selectedTab             = 0
    @State private var isRefreshing            = false
    
    @EnvironmentObject var userPreferences: UserPreferences
    
    // MARK: - Derived data ----------------------------------------------------
    
    /// Use real GPS when enabled; otherwise default to dummy co‑ordinate
    private var currentLocation: CLLocationCoordinate2D {
        if isLiveLocationEnabled,
           let loc = locationManager.location?.coordinate {
            return loc
        }
        return CLLocationCoordinate2D(latitude: 37.332, longitude: -122.031)
    }
    
    /// String to share via the standard iOS share sheet
    private var shareableLocationString: String {
        "I’m currently at: https://maps.apple.com/?ll=\(currentLocation.latitude),\(currentLocation.longitude)"
    }
    
    /// Alerts within approx. 5 miles of the user
    private var nearbyAlerts: [EmergencyAlert] {
        let radius: Double = 8_046.72   // metres
        return dummyAlerts.filter { alert in
            let userLoc  = CLLocation(latitude: currentLocation.latitude,
                                      longitude: currentLocation.longitude)
            let alertLoc = CLLocation(latitude: alert.coordinate.latitude,
                                      longitude: alert.coordinate.longitude)
            return userLoc.distance(from: alertLoc) <= radius
        }
    }
    
    // MARK: - View ------------------------------------------------------------
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // -----------------------------------------------------------------
            // 1. Alerts Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Live‑location bar
                        LocationStatusBar(
                            isLiveLocationEnabled: $isLiveLocationEnabled,
                            locationManager: locationManager,
                            showingNoPermissionAlert: $showingNoPermissionAlert
                        )
                        .padding(.horizontal)
                        
                        // Map of nearby alerts
                        VStack(alignment: .leading) {
                            Text("Nearby Alerts")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            MapView(
                                centerCoordinate: .constant(currentLocation),
                                annotations: nearbyAlerts.map {
                                    MapAnnotationItem(
                                        coordinate: $0.coordinate,
                                        title: $0.title,
                                        severity: $0.severity
                                    )
                                }
                            )
                            .frame(height: 220)
                            .cornerRadius(AppTheme.cornerRadius)
                            .padding(.horizontal)
                            .shadow(radius: 2)
                        }
                        
                        // Active alerts list
                        VStack(alignment: .leading) {
                            Text("Active Alerts")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if nearbyAlerts.isEmpty {
                                EmptyStateView(
                                    icon: "checkmark.shield.fill",
                                    title: "No Active Alerts",
                                    message: "There are currently no emergency alerts in your area."
                                )
                            } else {
                                ForEach(nearbyAlerts) { alert in
                                    NavigationLink {
                                        AlertDetailView(alert: alert)
                                    } label: {
                                        AlertCardView(alert: alert)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Safety tips carousel
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Safety Tips")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(dummySafetyTips) { tip in
                                        SafetyTipCardView(tip: tip)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Share location button
                        Button {
                            showShareSheet = true
                        } label: {
                            Label("Share My Location",
                                  systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primaryColor)
                                .cornerRadius(AppTheme.cornerRadius)
                                .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showShareSheet) {
                            ShareSheet(items: [shareableLocationString])
                        }
                    }
                    .padding(.vertical)
                }
                .navigationBarTitle("ark.AI", displayMode: .large)
                .navigationBarItems(
                    trailing: NavigationLink {
                        SettingsView(selectedRole: $selectedRole)
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(AppTheme.primaryColor)
                    }
                )
                .refreshable {
                    isRefreshing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isRefreshing = false
                    }
                }
                .alert(isPresented: $showingNoPermissionAlert) {
                    Alert(
                        title: Text("Location Permission Required"),
                        message: Text("To receive accurate alerts, please enable location permissions in Settings."),
                        primaryButton: .default(Text("Open Settings")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .tabItem {
                Image(systemName: "bell.fill")
                Text("Alerts")
            }
            .tag(0)
            
            // -----------------------------------------------------------------
            // 2. Social Feed Tab
            NavigationView {
                SocialFeedView()
                    .navigationBarTitle("Community Updates", displayMode: .inline)
            }
            .tabItem {
                Image(systemName: "text.bubble.fill")
                Text("Social")
            }
            .tag(1)
            
            // -----------------------------------------------------------------
            // 3. Resources Tab
            NavigationView {
                ResourcesView()
                    .navigationBarTitle("Resources", displayMode: .inline)
            }
            .tabItem {
                Image(systemName: "cross.fill")
                Text("Resources")
            }
            .tag(2)
            
            // -----------------------------------------------------------------
            // 4. Profile Tab
            NavigationView {
                ProfileView(selectedRole: $selectedRole)
                    .navigationBarTitle("Profile", displayMode: .inline)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
        }
        .accentColor(AppTheme.primaryColor)
    }
}
