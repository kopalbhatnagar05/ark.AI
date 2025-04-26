//
//  ResourcesView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// Consolidates emergency facilities, safety tips, contacts, and downloads
/// into a single scrollable screen.
struct ResourcesView: View {
    
    // MARK: - State
    @State private var selectedCategory: String? = nil
    
    // MARK: - Derived helpers -------------------------------------------------
    
    /// Group all dummy contacts by their `category`
    private var categorizedContacts: [String: [ResourceContact]] {
        Dictionary(grouping: dummyResourceContacts) { $0.category }
    }
    
    /// Sorted list of available categories
    private var categories: [String] {
        Array(categorizedContacts.keys).sorted()
    }
    
    /// Contacts filtered by the currently selected chip
    private var filteredContacts: [ResourceContact] {
        if let cat = selectedCategory {
            return dummyResourceContacts.filter { $0.category == cat }
        }
        return dummyResourceContacts
    }
    
    // MARK: - Body ------------------------------------------------------------
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // -------------------------------------------------------------
                // Emergency Facilities carousel
                sectionHeader("Emergency Facilities")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(dummyFacilities) { facility in
                            FacilityCardView(facility: facility)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // -------------------------------------------------------------
                // Safety Tips carousel
                sectionHeader("Safety Tips")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(dummySafetyTips) { tip in
                            SafetyTipCardView(tip: tip)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // -------------------------------------------------------------
                // Emergency Contacts list with category filter
                sectionHeader("Emergency Contacts")
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryPill(title: "All",
                                     isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(categories, id: \.self) { cat in
                            CategoryPill(title: cat,
                                         isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Contacts list
                VStack(spacing: 12) {
                    ForEach(filteredContacts) { contact in
                        ContactCardView(contact: contact)
                            .padding(.horizontal)
                    }
                }
                
                // -------------------------------------------------------------
                // Download emergency‑plan button
                Button {
                    // TODO: Hook up download / share action
                } label: {
                    Label("Download Emergency Plan PDF", systemImage: "arrow.down.doc.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.cornerRadius)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Little helper
    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Text(text).font(.headline)
            Spacer()
        }
        .padding(.horizontal)
    }
}
