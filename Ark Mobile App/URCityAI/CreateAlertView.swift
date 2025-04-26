//
//  CreateAlertView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


//
//  CreateAlertView.swift
//  URCityAI
//
//  Created on 17/04/25.
//

import SwiftUI
import MapKit

/// Form for city leaders to create and publish emergency alerts.
struct CreateAlertView: View {
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Form Data
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedSeverity: EmergencyAlert.AlertSeverity = .medium
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.332, longitude: -122.031),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var actionSteps: [String] = ["", ""]
    
    // MARK: - UI State
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var isSubmitting = false
    @State private var showConfirmation = false
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        NavigationView {
            Form {
                // Alert basics section
                Section(header: Text("Alert Details")) {
                    FormField(title: "Alert Title", text: $title, placeholder: "e.g. Flash Flood Warning")
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Severity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            ForEach(EmergencyAlert.AlertSeverity.allCases, id: \.self) { severity in
                                Button {
                                    selectedSeverity = severity
                                } label: {
                                    HStack {
                                        Image(systemName: severity.icon)
                                        Text(severity.rawValue)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .foregroundColor(.white)
                                    .background(selectedSeverity == severity ? severity.color : severity.color.opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                // Map location section
                Section(header: Text("Affected Area")) {
                    VStack {
                        Text("Tap and hold to set the alert location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Map(coordinateRegion: $region, interactionModes: .all)
                            .frame(height: 200)
                            .cornerRadius(AppTheme.cornerRadius)
                            .overlay(
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(selectedSeverity.color)
                                    .background(Color.white.clipShape(Circle()))
                            )
                    }
                }
                
                // Action steps section
                Section(header: Text("Action Steps")) {
                    ForEach(0..<actionSteps.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.secondary)
                            TextField("Add instruction", text: $actionSteps[index])
                        }
                    }
                    
                    Button {
                        actionSteps.append("")
                    } label: {
                        Label("Add Step", systemImage: "plus.circle")
                    }
                    
                    if actionSteps.count > 1 {
                        Button {
                            actionSteps.removeLast()
                        } label: {
                            Label("Remove Step", systemImage: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Preview & send section
                Section {
                    if !title.isEmpty && !description.isEmpty {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Alert Preview")
                                    .font(.headline)
                                
                                AlertCardView(alert: previewAlert)
                                    .frame(maxWidth: .infinity)
                            }
                            Spacer()
                        }
                    }
                    
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
                                    Text("Publish Alert")
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
            .navigationBarTitle("Create Alert", displayMode: .inline)
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
                    title: Text("Alert Published"),
                    message: Text("Your emergency alert has been sent to all users in the affected area."),
                    dismissButton: .default(Text("Done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Helpers ---------------------------------------------------------
    
    /// Creates a preview alert for the card view based on current form data
    private var previewAlert: EmergencyAlert {
        EmergencyAlert(
            title: title,
            description: description,
            severity: selectedSeverity,
            coordinate: region.center,
            timeStamp: Date(),
            actionSteps: actionSteps.filter { !$0.isEmpty }
        )
    }
    
    /// Validates form data before submission
    private func validateForm() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter an alert title"
            return false
        }
        
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter an alert description"
            return false
        }
        
        let validSteps = actionSteps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if validSteps.isEmpty {
            validationMessage = "Please add at least one action step"
            return false
        }
        
        return true
    }
}