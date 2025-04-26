//
//  AddContactView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


//
//  AddContactView.swift
//  URCityAI
//
//  Created on 17/04/25.
//

import SwiftUI

/// Form for city leaders to add emergency contact information.
struct AddContactView: View {
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Form Data
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var website: String = ""
    @State private var category: String = ""
    
    // MARK: - Contact Categories
    let categories = ["Emergency", "Medical", "Police", "Fire", "Crisis Support", "Utility", "Government", "Other"]
    
    // MARK: - UI State
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var isSubmitting = false
    @State private var showConfirmation = false
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        NavigationView {
            Form {
                // Basic contact details section
                Section(header: Text("Contact Details")) {
                    FormField(title: "Name", text: $name, placeholder: "e.g. City Emergency Management")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Category", selection: $category) {
                            Text("Select Category").tag("")
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                    }
                }
                
                // Contact information section
                Section(header: Text("Contact Information")) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.secondary)
                        TextField("Website (optional)", text: $website)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                }
                
                // Preview section
                Section(header: Text("Preview")) {
                    if !name.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(AppTheme.primaryColor)
                                
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .font(.headline)
                                    
                                    if !category.isEmpty {
                                        Text(category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "phone.circle.fill")
                                    .foregroundColor(.green)
                            }
                            
                            if !phoneNumber.isEmpty {
                                Text(phoneNumber)
                                    .foregroundColor(.blue)
                            }
                            
                            if !website.isEmpty {
                                Text(website)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
                                    Text("Add Contact")
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
            .navigationBarTitle("Add Contact", displayMode: .inline)
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
                    title: Text("Contact Added"),
                    message: Text("The contact has been successfully added to the system."),
                    dismissButton: .default(Text("Done")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Helpers ---------------------------------------------------------
    
    /// Creates a new ResourceContact object from the form data
    private func createContact() -> ResourceContact {
        ResourceContact(
            name: name,
            phoneNumber: phoneNumber,
            website: website.isEmpty ? nil : website,
            category: category
        )
    }
    
    /// Validates form data before submission
    private func validateForm() -> Bool {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a name for the contact"
            return false
        }
        
        if phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a phone number"
            return false
        }
        
        if category.isEmpty {
            validationMessage = "Please select a category"
            return false
        }
        
        return true
    }
}