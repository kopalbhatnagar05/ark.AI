//
//  ProfileView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// Personal profile screen with edit capability and link to Settings.
struct ProfileView: View {
    
    // MARK: - Bindings
    @Binding var selectedRole: UserRole?
    
    // MARK: - Local editable fields
    @State private var username    = "Arjun Lamba"
    @State private var phoneNumber = "555‑123‑4567"
    @State private var email       = "alamba@ucdavis.edu"
    @State private var address     = "6455 Clement St, San Francisco"
    
    // MARK: - UI state
    @State private var isEditing = false
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // ---------------------------------------------------------
                // Avatar + role badge
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(AppTheme.primaryColor)
                    
                    Text(username)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(selectedRole?.rawValue ?? "Individual")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.primaryColor)
                }
                .padding()
                
                // ---------------------------------------------------------
                // Personal information
                VStack(alignment: .leading, spacing: 20) {
                    Text("Personal Information")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if isEditing {
                        // EDIT MODE
                        VStack(spacing: 15) {
                            FormField(title: "Name",
                                      text: $username,
                                      placeholder: "Enter your name")
                            
                            FormField(title: "Phone Number",
                                      text: $phoneNumber,
                                      placeholder: "Enter phone number")
                                .keyboardType(.phonePad)
                            
                            FormField(title: "Email",
                                      text: $email,
                                      placeholder: "Enter email address")
                                .keyboardType(.emailAddress)
                            
                            FormField(title: "Address",
                                      text: $address,
                                      placeholder: "Enter your address")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(AppTheme.cornerRadius)
                        .padding(.horizontal)
                        
                        // Save / Cancel
                        HStack {
                            Button("Cancel") { isEditing = false }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(AppTheme.cornerRadius)
                            
                            Button("Save") {
                                // TODO: Persist edits here
                                isEditing = false
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryColor)
                            .cornerRadius(AppTheme.cornerRadius)
                        }
                        .padding(.horizontal)
                        
                    } else {
                        // VIEW MODE
                        InfoRow(label: "Phone",
                                value: phoneNumber,
                                icon: "phone.fill")
                            .padding(.horizontal)
                        
                        Divider().padding(.horizontal)
                        
                        InfoRow(label: "Email",
                                value: email,
                                icon: "envelope.fill")
                            .padding(.horizontal)
                        
                        Divider().padding(.horizontal)
                        
                        InfoRow(label: "Address",
                                value: address,
                                icon: "location.fill")
                            .padding(.horizontal)
                        
                        // Edit button
                        Button {
                            isEditing = true
                        } label: {
                            Label("Edit Profile", systemImage: "pencil")
                                .foregroundColor(AppTheme.primaryColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primaryColor.opacity(0.1))
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
                
                // ---------------------------------------------------------
                // Settings link
                NavigationLink {
                    SettingsView(selectedRole: $selectedRole)
                } label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal)
                }
                
                // ---------------------------------------------------------
                // Help & Support placeholder
                Button {
                    // TODO: Provide help centre navigation
                } label: {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Help & Support")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitle("Profile", displayMode: .inline)
    }
}

// MARK: - Info row sub‑component ----------------------------------------------

struct InfoRow: View {
    let label: String
    let value: String
    let icon : String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
            }
            Spacer()
            
            // Quick action buttons
            if label == "Phone" {
                quickActionButton("tel:\(value.filter { $0.isNumber })",
                                  systemIcon: "phone.circle.fill")
            } else if label == "Email" {
                quickActionButton("mailto:\(value)",
                                  systemIcon: "envelope.circle.fill")
            } else if label == "Address" {
                if let encoded = value.addingPercentEncoding(
                        withAllowedCharacters: .urlQueryAllowed) {
                    quickActionButton("maps://?address=\(encoded)",
                                      systemIcon: "map.circle.fill")
                }
            }
        }
    }
    
    @ViewBuilder
    private func quickActionButton(_ urlString: String,
                                   systemIcon: String) -> some View {
        if let url = URL(string: urlString) {
            Button { UIApplication.shared.open(url) } label: {
                Image(systemName: systemIcon)
                    .foregroundColor(AppTheme.primaryColor)
                    .font(.title3)
            }
        }
    }
}
