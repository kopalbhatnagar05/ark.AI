//
//  UserPreferences.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


import SwiftUI
import Combine

/// Stores user‑configurable settings (notifications, contacts, dark mode)
/// and persists them with `UserDefaults`.
final class UserPreferences: ObservableObject {
    
    // MARK: - Published settings --------------------------------------------
    
    @Published var enableNotifications: Bool {
        didSet { UserDefaults.standard.set(enableNotifications,
                                           forKey: Keys.enableNotifications) }
    }
    
    /// Set of raw strings (“critical”, “weather”, …) representing enabled types.
    @Published var notificationTypes: Set<String> {
        didSet {
            if let data = try? JSONEncoder().encode(Array(notificationTypes)) {
                UserDefaults.standard.set(data, forKey: Keys.notificationTypes)
            }
        }
    }
    
    /// Simple list of emergency contact strings (phone numbers, names, etc.).
    @Published var emergencyContacts: [String] {
        didSet {
            if let data = try? JSONEncoder().encode(emergencyContacts) {
                UserDefaults.standard.set(data, forKey: Keys.emergencyContacts)
            }
        }
    }
    
    /// Dark‑mode preference (overrides system if true/false)
    @Published var darkModeEnabled: Bool {
        didSet { UserDefaults.standard.set(darkModeEnabled,
                                           forKey: Keys.darkModeEnabled) }
    }
    
    // MARK: - Init -----------------------------------------------------------
    
    init() {
        // Notifications toggle
        enableNotifications = UserDefaults.standard.bool(forKey: Keys.enableNotifications)
        
        // Notification types
        if let data = UserDefaults.standard.data(forKey: Keys.notificationTypes),
           let array = try? JSONDecoder().decode([String].self, from: data) {
            notificationTypes = Set(array)
        } else {
            notificationTypes = ["critical", "weather", "traffic", "community"]
        }
        
        // Emergency contacts
        if let data = UserDefaults.standard.data(forKey: Keys.emergencyContacts),
           let contacts = try? JSONDecoder().decode([String].self, from: data) {
            emergencyContacts = contacts
        } else {
            emergencyContacts = []
        }
        
        // Dark mode
        darkModeEnabled = UserDefaults.standard.bool(forKey: Keys.darkModeEnabled)
    }
    
    // MARK: - UserDefaults keys ---------------------------------------------
    private enum Keys {
        static let enableNotifications = "enableNotifications"
        static let notificationTypes   = "notificationTypes"
        static let emergencyContacts   = "emergencyContacts"
        static let darkModeEnabled     = "darkModeEnabled"
    }
}
