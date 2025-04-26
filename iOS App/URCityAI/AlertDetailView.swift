//
//  AlertDetailView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI
import MapKit

/// Drill‑down screen for a single emergency alert.
/// Shows header, description, expandable map, action steps, and key contacts.
struct AlertDetailView: View {
    
    // MARK: - Data
    let alert: EmergencyAlert
    
    // MARK: - UI State
    @State private var isMapExpanded = false
    @State private var showShareSheet = false
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // -----------------------------------------------------------
                // Header with severity badge
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(alert.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(formattedDate(alert.timeStamp))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(alert.severity.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(alert.severity.color)
                        .cornerRadius(10)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(AppTheme.cornerRadius)
                
                // -----------------------------------------------------------
                // Description block
                sectionCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Description").font(.headline)
                        Text(alert.description)
                            .foregroundColor(.secondary)
                    }
                }
                
                // -----------------------------------------------------------
                // Location / Map
                sectionCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Location").font(.headline)
                            Spacer()
                            Button(isMapExpanded ? "Collapse" : "Expand") {
                                withAnimation { isMapExpanded.toggle() }
                            }
                            .font(.caption)
                            .foregroundColor(AppTheme.primaryColor)
                        }
                        
                        MapView(
                            centerCoordinate: .constant(alert.coordinate),
                            annotations: [
                                MapAnnotationItem(
                                    coordinate: alert.coordinate,
                                    title: alert.title,
                                    severity: alert.severity)
                            ]
                        )
                        .frame(height: isMapExpanded ? 300 : 180)
                        .cornerRadius(AppTheme.cornerRadius)
                        .animation(.spring(), value: isMapExpanded)
                    }
                }
                
                // -----------------------------------------------------------
                // Action steps
                sectionCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Action Steps").font(.headline)
                        ForEach(Array(alert.actionSteps.enumerated()),
                                id: \.offset) { idx, step in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(AppTheme.primaryColor)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text("\(idx + 1)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                Text(step).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // -----------------------------------------------------------
                // Emergency contacts (top two for brevity)
                sectionCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Emergency Contacts").font(.headline)
                        ForEach(dummyResourceContacts.prefix(2)) { contact in
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(AppTheme.primaryColor)
                                Text(contact.name)
                                Spacer()
                                Text(contact.phoneNumber)
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                    }
                }
                
                // -----------------------------------------------------------
                // Share alert
                Button {
                    showShareSheet = true
                } label: {
                    Label("Share This Alert", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.cornerRadius)
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [shareString])
                }
            }
            .padding()
        }
        .navigationBarTitle("Alert Details", displayMode: .inline)
    }
    
    // MARK: - Helpers ---------------------------------------------------------
    
    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
    
    private var shareString: String {
        "\(alert.title) – \(alert.description)"
    }
    
    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(AppTheme.cornerRadius)
    }
}
