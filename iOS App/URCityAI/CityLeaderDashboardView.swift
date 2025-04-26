//
//  CityLeaderDashboardView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI
import MapKit

/// Multi‑tab control centre for city officials / emergency managers.
struct CityLeaderDashboardView: View {
    
    // MARK: - Bindings / State
    @Binding var selectedRole: UserRole?
    @State private var selectedTab           = 0
    @State private var showingCreateAlert    = false
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // -----------------------------------------------------------------
            // 1. Overview Dashboard
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // At‑a‑glance stats
                        HStack(spacing: 15) {
                            StatCard(title: "Active Alerts",
                                     value: "\(dummyAlerts.count)",
                                     icon: "bell.fill",
                                     color: AppTheme.dangerColor)
                            
                            StatCard(title: "Facilities",
                                     value: "\(dummyFacilities.count)",
                                     icon: "building.2.fill",
                                     color: AppTheme.primaryColor)
                        }
                        .padding(.horizontal)
                        
                        // Small map preview
                        VStack(alignment: .leading) {
                            Text("Alert Overview")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            MapView(
                                centerCoordinate: .constant(
                                    CLLocationCoordinate2D(
                                        latitude: 37.332, longitude: -122.031)),
                                annotations: dummyAlerts.map {
                                    MapAnnotationItem(
                                        coordinate: $0.coordinate,
                                        title: $0.title,
                                        severity: $0.severity)
                                }
                            )
                            .frame(height: 220)
                            .cornerRadius(AppTheme.cornerRadius)
                            .padding(.horizontal)
                        }
                        
                        // Active alerts list
                        VStack(alignment: .leading) {
                            Text("Active Alerts")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(dummyAlerts) { alert in
                                AlertCardView(alert: alert)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Facilities status list
                        VStack(alignment: .leading) {
                            Text("Facility Status")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(dummyFacilities) { facility in
                                FacilityStatusCard(facility: facility)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationBarTitle("City Dashboard", displayMode: .large)
                .navigationBarItems(
                    leading: Button("Change Role") { selectedRole = nil }
                        .foregroundColor(AppTheme.primaryColor),
                    trailing: Button {
                        showingCreateAlert = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.primaryColor)
                    }
                )
                .sheet(isPresented: $showingCreateAlert) {
                    CreateAlertView()
                }
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Dashboard")
            }
            .tag(0)
            
            // -----------------------------------------------------------------
            // 2. Alerts Management (placeholder for future CRUD UI)
            AlertsManagementView()
                            .tabItem {
                                Image(systemName: "bell.fill")
                                Text("Alerts")
                            }
                            .tag(1)
            
            // -----------------------------------------------------------------
            // 3. Resource Management (placeholder)
            ResourceManagementView()
                            .tabItem {
                                Image(systemName: "cross.fill")
                                Text("Resources")
                            }
                            .tag(2)
            
            // -----------------------------------------------------------------
            // 4. Admin Settings (placeholder)
            AdminSettingsView()
                            .tabItem {
                                Image(systemName: "gear")
                                Text("Settings")
                            }
                            .tag(3)
        }
        .accentColor(AppTheme.primaryColor)
    }
}
