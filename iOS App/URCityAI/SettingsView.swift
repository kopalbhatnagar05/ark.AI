//
//  SettingsView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// Central settings for notifications, appearance, account, and about.
struct SettingsView: View {
    
    // MARK: Bindings & Environment
    @Binding var selectedRole: UserRole?
    @EnvironmentObject var userPreferences: UserPreferences
    
    // MARK: Local UI state
    @State private var showDeleteAccountAlert = false
    
    // MARK: Body --------------------------------------------------------------
    var body: some View {
        Form {
            // -------------------------------------------------------------
            // Notifications
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications",
                       isOn: $userPreferences.enableNotifications)
                
                if userPreferences.enableNotifications {
                    Toggle("Critical Alerts",
                           isOn: bindingFor("critical"))
                    Toggle("Weather Alerts",
                           isOn: bindingFor("weather"))
                    Toggle("Traffic Updates",
                           isOn: bindingFor("traffic"))
                    Toggle("Community Updates",
                           isOn: bindingFor("community"))
                }
            }
            
            // -------------------------------------------------------------
            // Emergency contacts
            Section(header: Text("Emergency Contacts")) {
                ForEach(userPreferences.emergencyContacts,
                        id: \.self) { contact in
                    Text(contact)
                }
                .onDelete(perform: deleteContact)
                
                Button {
                    // TODO: Present add‑contact workflow
                } label: {
                    Label("Add Emergency Contact", systemImage: "plus")
                }
            }
            
            // -------------------------------------------------------------
            // Appearance
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $userPreferences.darkModeEnabled)
            }
            
            // -------------------------------------------------------------
            // Account management
            Section(header: Text("Account")) {
                Button("Change User Role") {
                    selectedRole = nil
                }
                Button("Sign Out") {
                    // TODO: implement auth sign‑out
                }
                Button("Delete Account") {
                    showDeleteAccountAlert = true
                }
                .foregroundColor(.red)
            }
            
            // -------------------------------------------------------------
            // About
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0").foregroundColor(.secondary)
                }
                Button("Privacy Policy")  { /* open link */ }
                Button("Terms of Service") { /* open link */ }
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .alert(isPresented: $showDeleteAccountAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // TODO: Delete account logic
                    selectedRole = nil
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: Helpers -----------------------------------------------------------
    
    /// Generates a binding for toggling individual notification types.
    private func bindingFor(_ type: String) -> Binding<Bool> {
        Binding {
            userPreferences.notificationTypes.contains(type)
        } set: { newVal in
            if newVal {
                userPreferences.notificationTypes.insert(type)
            } else {
                userPreferences.notificationTypes.remove(type)
            }
        }
    }
    
    private func deleteContact(at indexSet: IndexSet) {
        userPreferences.emergencyContacts.remove(atOffsets: indexSet)
    }
}
