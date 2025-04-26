//
//  AlertsManagementView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


//
//  AlertsManagementView.swift
//  URCityAI
//
//  Created on 17/04/25.
//

import SwiftUI

/// CRUD interface for city leaders to manage emergency alerts.
struct AlertsManagementView: View {
    // MARK: - State
    @State private var showingCreateAlert = false
    @State private var selectedFilter: AlertFilter = .all
    @State private var searchText = ""
    @State private var showingAlertToDelete: EmergencyAlert? = nil
    
    // This would come from a real data source in a production app
    @State private var alerts = dummyAlerts
    
    // MARK: - Computed
    private var filteredAlerts: [EmergencyAlert] {
        var filtered = alerts
        
        // Apply filter
        if selectedFilter != .all {
            filtered = filtered.filter { alert in
                switch selectedFilter {
                case .critical:
                    return alert.severity == .critical
                case .high:
                    return alert.severity == .high
                case .medium:
                    return alert.severity == .medium
                case .low:
                    return alert.severity == .low
                case .all:
                    return true
                }
            }
        }
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { alert in
                alert.title.lowercased().contains(searchText.lowercased()) ||
                alert.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        return filtered
    }
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search alerts", text: $searchText)
                        .foregroundColor(.primary)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding()
                
                // Horizontal filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(AlertFilter.allCases, id: \.self) { filter in
                            CategoryPill(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter,
                                color: filter.color
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Alert list
                if filteredAlerts.isEmpty {
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No Alerts Found",
                        message: "There are no alerts matching your criteria"
                    )
                } else {
                    List {
                        ForEach(filteredAlerts) { alert in
                            NavigationLink(destination: AlertDetailView(alert: alert)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: alert.severity.icon)
                                                .foregroundColor(alert.severity.color)
                                            Text(alert.title)
                                                .font(.headline)
                                        }
                                        
                                        Text(formatDate(alert.timeStamp))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Status indicator - in a real app, this could show
                                    // active/expired/draft status
                                    Text("Active")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        showingAlertToDelete = alert
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        // In a real app, this would navigate to an edit form
                                        print("Edit tapped")
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Manage Alerts", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                showingCreateAlert = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            })
            .sheet(isPresented: $showingCreateAlert) {
                CreateAlertView()
            }
            .alert(item: $showingAlertToDelete) { alert in
                Alert(
                    title: Text("Delete Alert"),
                    message: Text("Are you sure you want to delete '\(alert.title)'?"),
                    primaryButton: .destructive(Text("Delete")) {
                        // Remove the alert from our collection
                        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
                            alerts.remove(at: index)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Filter options for alerts
    enum AlertFilter: String, CaseIterable {
        case all = "All"
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .all: return .gray
            case .critical: return .red
            case .high: return AppTheme.dangerColor
            case .medium: return AppTheme.warningColor
            case .low: return AppTheme.primaryColor
            }
        }
    }
}


