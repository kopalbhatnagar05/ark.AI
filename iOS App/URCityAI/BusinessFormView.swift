//
//  BusinessFormView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// Registration flow for local businesses so they can receive
/// targeted emergency alerts and share capacity/status data.
struct BusinessFormView: View {
    
    // MARK: - Environment / Bindings
    @Binding var selectedRole: UserRole?
    
    // MARK: - Form fields
    @State private var businessName = ""
    @State private var businessType = ""
    @State private var address      = ""
    @State private var phoneNumber  = ""
    @State private var email        = ""
    
    // MARK: - UI state
    @State private var isSubmitting       = false
    @State private var showingSuccessAlert = false
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Text("Register Your Business")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Provide your business information to receive targeted emergency alerts and support.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Form container
                    VStack(spacing: 15) {
                        FormField(title: "Business Name",
                                  text: $businessName,
                                  placeholder: "Enter business name")
                        
                        FormField(title: "Business Type",
                                  text: $businessType,
                                  placeholder: "e.g. Retail, Restaurant, Service")
                        
                        FormField(title: "Address",
                                  text: $address,
                                  placeholder: "Enter full address")
                        
                        FormField(title: "Phone Number",
                                  text: $phoneNumber,
                                  placeholder: "Enter phone number")
                            .keyboardType(.phonePad)
                        
                        FormField(title: "Email",
                                  text: $email,
                                  placeholder: "Enter email address")
                            .keyboardType(.emailAddress)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal)
                    
                    // Submit button
                    Button {
                        submitForm()
                    } label: {
                        HStack {
                            Text("Register Business")
                                .fontWeight(.semibold)
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .padding(.leading, 5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(formIsValid
                                    ? AppTheme.primaryColor
                                    : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.cornerRadius)
                    }
                    .disabled(!formIsValid || isSubmitting)
                    .padding(.horizontal)
                    
                    // Back link
                    Button("Go Back") {
                        selectedRole = nil
                    }
                    .padding(.top, 5)
                    .foregroundColor(AppTheme.primaryColor)
                }
                .padding(.bottom)
            }
            .navigationBarTitle("Business Registration", displayMode: .inline)
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Registration Successful"),
                    message: Text("Your business has been registered. You'll now receive relevant alerts."),
                    dismissButton: .default(Text("Continue to Dashboard")) {
                        // Optionally navigate to a business dashboard later
                    }
                )
            }
        }
    }
    
    // MARK: - Helpers ---------------------------------------------------------
    
    private var formIsValid: Bool {
        !businessName.isEmpty &&
        !businessType.isEmpty &&
        !address.isEmpty &&
        !phoneNumber.isEmpty &&
        !email.isEmpty
    }
    
    private func submitForm() {
        isSubmitting = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showingSuccessAlert = true
            // Here you would POST to your backend / Firestore / etc.
        }
    }
}
