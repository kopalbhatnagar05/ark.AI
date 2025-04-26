//
//  AddSafetyTipView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


//
//  AddSafetyTipView.swift
//  URCityAI
//
//  Created on 17/04/25.
//

import SwiftUI

/// Form for city leaders to add safety tips and educational content.
struct AddSafetyTipView: View {
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Form Data
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedIcon: String = "lightbulb.fill"
    
    // MARK: - UI State
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var isSubmitting = false
    @State private var showConfirmation = false
    
    // Common system icons for safety tips
    let availableIcons = [
        "lightbulb.fill", "flame.fill", "drop.fill", "tornado", "hurricane", 
        "bolt.fill", "cross.fill", "staroflife.fill", "shield.fill", 
        "exclamationmark.triangle.fill", "house.fill", "car.fill", "airplane", 
        "hand.raised.fill", "waveform.path.ecg", "bandage.fill", "face.smiling",
        "leaf.fill", "sun.max.fill", "snowflake", "cloud.rain.fill"
    ]
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        NavigationView {
            Form {
                // Basic tip details section
                Section(header: Text("Safety Tip Details")) {
                    FormField(title: "Title", text: $title, placeholder: "e.g. How to Prepare for a Hurricane")
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                // Icon selection section
                Section(header: Text("Select Icon")) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 60))
                    ], spacing: 15) {
                        ForEach(availableIcons, id: \.self) { iconName in
                            Button {
                                selectedIcon = iconName
                            } label: {
                                VStack {
                                    Image(systemName: iconName)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedIcon == iconName ? AppTheme.primaryColor : .gray)
                                        .padding(12)
                                }
                                .background(
                                    Circle()
                                        .fill(selectedIcon == iconName ? AppTheme.primaryColor.opacity(0.2) : Color.clear)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(selectedIcon == iconName ? AppTheme.primaryColor : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                // Preview section
                Section(header: Text("Preview")) {
                    if !title.isEmpty {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: selectedIcon)
                                .font(.title2)
                                .foregroundColor(AppTheme.primaryColor)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(title)
                                    .font(.headline)
                                
                                if !description.isEmpty {
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text("Fill in the details above to see a preview")
                            .foregroundColor(.secondary)
                            .italic()
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
                                    Text("Add Safety Tip")
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
            .navigationBarTitle("Add Safety Tip", displayMode: .inline)
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
                    title: Text("Safety Tip Added"),
                    message: Text("The safety tip has been successfully added to the system."),
                    dismissButton: .default(Text("Done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Helpers ---------------------------------------------------------
    
    /// Creates a new SafetyTip object from the form data
    private func createSafetyTip() -> SafetyTip {
        SafetyTip(
            title: title,
            description: description,
            iconName: selectedIcon
        )
    }
    
    /// Validates form data before submission
    private func validateForm() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a title for the safety tip"
            return false
        }
        
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a description for the safety tip"
            return false
        }
        
        return true
    }
}