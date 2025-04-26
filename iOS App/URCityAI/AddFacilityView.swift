//
//  AddFacilityView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


//
//  AddFacilityView.swift
//  URCityAI
//
//  Created on 17/04/25.
//

import SwiftUI
import MapKit

/// Form for city leaders to add emergency resource facilities.
struct AddFacilityView: View {
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Form Data
    @State private var name: String = ""
    @State private var facilityType: String = ""
    @State private var currentCapacity: String = ""
    @State private var totalCapacity: String = ""
    @State private var address: String = ""
    @State private var contactInfo: String = ""
    @State private var services: [String] = [""]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.332, longitude: -122.031),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // MARK: - Facility Types
    let facilityTypes = ["Hospital", "Shelter", "Police Station", "Fire Station", "Food Bank", "Water Supply", "Evacuation Center", "Other"]
    
    // MARK: - UI State
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var isSubmitting = false
    @State private var showConfirmation = false
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        NavigationView {
            Form {
                // Basic facility details section
                Section(header: Text("Facility Details")) {
                    FormField(title: "Facility Name", text: $name, placeholder: "e.g. Central Hospital")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Facility Type")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Facility Type", selection: $facilityType) {
                            Text("Select Type").tag("")
                            ForEach(facilityTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Capacity")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Current", text: $currentCapacity)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Capacity")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Maximum", text: $totalCapacity)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Location section
                Section(header: Text("Location")) {
                    FormField(title: "Address", text: $address, placeholder: "Full street address")
                    
                    VStack {
                        Text("Tap and hold to set the facility location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Map(coordinateRegion: $region, interactionModes: .all)
                            .frame(height: 200)
                            .cornerRadius(AppTheme.cornerRadius)
                            .overlay(
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(AppTheme.primaryColor)
                                    .background(Color.white.clipShape(Circle()))
                            )
                    }
                }
                
                // Contact info section
                Section(header: Text("Contact Information")) {
                    FormField(title: "Contact Information", text: $contactInfo, placeholder: "Phone number, email, etc.")
                }
                
                // Services section
                Section(header: Text("Available Services")) {
                    ForEach(0..<services.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.secondary)
                            TextField("Add service", text: $services[index])
                        }
                    }
                    
                    Button {
                        services.append("")
                    } label: {
                        Label("Add Service", systemImage: "plus.circle")
                    }
                    
                    if services.count > 1 {
                        Button {
                            services.removeLast()
                        } label: {
                            Label("Remove Service", systemImage: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Submit button section
                Section {
                    Button {
                        if validateForm() {
                            isSubmitting = true
                            // Simulate network delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isSubmitting = false
                                showConfirmation = true
                            }
                        } else {
                            showValidationAlert = true
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Group {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Add Facility")
                                        .fontWeight(.bold)
                                }
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSubmitting)
                    .listRowBackground(AppTheme.primaryColor)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitle("Add Facility", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showValidationAlert) {
                Alert(
                    title: Text("Incomplete Information"),
                    message: Text(validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text("Facility Added"),
                    message: Text("The facility has been successfully added to the system."),
                    dismissButton: .default(Text("Done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Helpers ---------------------------------------------------------
    
    /// Creates a new Facility object from the form data
    private func createFacility() -> Facility {
        Facility(
            name: name,
            type: facilityType,
            currentCapacity: Int(currentCapacity) ?? 0,
            totalCapacity: Int(totalCapacity) ?? 0,
            coordinate: region.center,
            address: address,
            contactInfo: contactInfo,
            services: services.filter { !$0.isEmpty }
        )
    }
    
    /// Validates form data before submission
    private func validateForm() -> Bool {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a facility name"
            return false
        }
        
        if facilityType.isEmpty {
            validationMessage = "Please select a facility type"
            return false
        }
        
        if currentCapacity.isEmpty || Int(currentCapacity) == nil {
            validationMessage = "Please enter a valid current capacity"
            return false
        }
        
        if totalCapacity.isEmpty || Int(totalCapacity) == nil {
            validationMessage = "Please enter a valid total capacity"
            return false
        }
        
        if let current = Int(currentCapacity), let total = Int(totalCapacity), current > total {
            validationMessage = "Current capacity cannot exceed total capacity"
            return false
        }
        
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter an address"
            return false
        }
        
        if contactInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter contact information"
            return false
        }
        
        let validServices = services.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if validServices.isEmpty {
            validationMessage = "Please add at least one service"
            return false
        }
        
        return true
    }
}