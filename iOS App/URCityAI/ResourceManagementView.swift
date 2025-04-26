//
//  ResourceManagementView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


//
//  ResourceManagementView.swift
//  URCityAI
//
//  Created on 17/04/25.
//

import SwiftUI
import MapKit

/// Interface for city leaders to manage emergency resources and facilities.
struct ResourceManagementView: View {
    // MARK: - State
    @State private var selectedResourceType: ResourceType = .facilities
    @State private var showingAddResource = false
    @State private var searchText = ""
    
    // In a real app, these would be loaded from a database or API
    @State private var facilities = dummyFacilities
    @State private var safetyTips = dummySafetyTips
    @State private var contacts = dummyResourceContacts
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Resource type picker
                Picker("Resource Type", selection: $selectedResourceType) {
                    ForEach(ResourceType.allCases, id: \.self) { type in
                        Label(
                            type.rawValue,
                            systemImage: type.icon
                        ).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search \(selectedResourceType.rawValue.lowercased())", text: $searchText)
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
                .padding(.horizontal)
                
                // Content based on selected resource type
                switch selectedResourceType {
                case .facilities:
                    facilitiesView
                case .safetyTips:
                    safetyTipsView
                case .contacts:
                    contactsView
                }
            }
            .navigationBarTitle("Resource Management", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                showingAddResource = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            })
            .sheet(isPresented: $showingAddResource) {
                // Different form based on resource type
                getAddResourceForm()
            }
        }
    }
    
    // MARK: - Resource Views
    
    // Facilities List/Map View
    private var facilitiesView: some View {
        VStack {
            // Map preview of facilities
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.332, longitude: -122.031),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )), annotationItems: filteredFacilities) { facility in
                MapMarker(coordinate: facility.coordinate, tint: .blue)
            }
            .frame(height: 200)
            .cornerRadius(AppTheme.cornerRadius)
            .padding()
            
            // Facilities list
            List {
                ForEach(filteredFacilities) { facility in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.blue)
                            Text(facility.name)
                                .font(.headline)
                            Spacer()
                            Text(facility.type)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                        
                        // Capacity indicator
                        HStack {
                            Text("Capacity:")
                                .foregroundColor(.secondary)
                            
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 8)
                                        .opacity(0.3)
                                        .foregroundColor(.gray)
                                    
                                    Rectangle()
                                        .frame(width: min(CGFloat(facility.currentCapacity) / CGFloat(facility.totalCapacity) * geometry.size.width, geometry.size.width), height: 8)
                                        .foregroundColor(getCapacityColor(current: facility.currentCapacity, total: facility.totalCapacity))
                                }
                                .cornerRadius(4)
                            }
                            .frame(height: 8)
                            
                            Text("\(facility.currentCapacity)/\(facility.totalCapacity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(facility.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .swipeActions {
                        Button(role: .destructive) {
                            if let index = facilities.firstIndex(where: { $0.id == facility.id }) {
                                facilities.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            // Edit action placeholder
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
    }
    
    // Safety Tips List View
    private var safetyTipsView: some View {
        List {
            ForEach(filteredSafetyTips) { tip in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: tip.iconName)
                        .font(.title2)
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(tip.title)
                            .font(.headline)
                        
                        Text(tip.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .swipeActions {
                    Button(role: .destructive) {
                        if let index = safetyTips.firstIndex(where: { $0.id == tip.id }) {
                            safetyTips.remove(at: index)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        // Edit action placeholder
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
    }
    
    // Contacts List View
    private var contactsView: some View {
        List {
            ForEach(filteredContacts) { contact in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(AppTheme.primaryColor)
                        
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(.headline)
                            
                            Text(contact.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "phone.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text(contact.phoneNumber)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        if let website = contact.website {
                            Text(website)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
                .swipeActions {
                    Button(role: .destructive) {
                        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
                            contacts.remove(at: index)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        // Edit action placeholder
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
    }
    

    // MARK: - Helper Functions
        
    // Returns appropriate form based on selected resource type
    @ViewBuilder
    private func getAddResourceForm() -> some View {
        switch selectedResourceType {
        case .facilities:
            AddFacilityView()
        case .safetyTips:
            AddSafetyTipView()
        case .contacts:
            AddContactView()
        }
    }
    
    // Color for capacity indicator
    private func getCapacityColor(current: Int, total: Int) -> Color {
        let percentage = Double(current) / Double(total)
        if percentage < 0.5 {
            return .green
        } else if percentage < 0.8 {
            return AppTheme.warningColor
        } else {
            return AppTheme.dangerColor
        }
    }
    
    // MARK: - Computed Properties for Filtering
    
    private var filteredFacilities: [Facility] {
        if searchText.isEmpty {
            return facilities
        } else {
            return facilities.filter { facility in
                facility.name.localizedCaseInsensitiveContains(searchText) ||
                facility.type.localizedCaseInsensitiveContains(searchText) ||
                facility.address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var filteredSafetyTips: [SafetyTip] {
        if searchText.isEmpty {
            return safetyTips
        } else {
            return safetyTips.filter { tip in
                tip.title.localizedCaseInsensitiveContains(searchText) ||
                tip.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var filteredContacts: [ResourceContact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchText) ||
                contact.category.localizedCaseInsensitiveContains(searchText) ||
                contact.phoneNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Resource type enum
    enum ResourceType: String, CaseIterable {
        case facilities = "Facilities"
        case safetyTips = "Safety Tips"
        case contacts = "Contacts"
        
        var icon: String {
            switch self {
            case .facilities: return "building.2.fill"
            case .safetyTips: return "lightbulb.fill"
            case .contacts: return "person.crop.circle.fill"
            }
        }
    }
}
