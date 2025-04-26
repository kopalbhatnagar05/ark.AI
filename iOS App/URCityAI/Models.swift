//
//  Models.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI               // for Color
import CoreLocation          // for CLLocationCoordinate2D

// MARK: - Emergency Alert -----------------------------------------------------

struct EmergencyAlert: Identifiable {
    let id          = UUID()
    let title       : String
    let description : String
    let severity    : AlertSeverity
    let coordinate  : CLLocationCoordinate2D
    let timeStamp   : Date
    let actionSteps : [String]
    
    /// Four‑level severity with helper icon / colour.
    enum AlertSeverity: String, CaseIterable {
        case critical = "Critical"
        case high     = "High"
        case medium   = "Medium"
        case low      = "Low"
        
        var color: Color {
            switch self {
            case .critical: return .red
            case .high:     return AppTheme.dangerColor
            case .medium:   return AppTheme.warningColor
            case .low:      return AppTheme.primaryColor
            }
        }
        
        var icon: String {
            switch self {
            case .critical: return "exclamationmark.triangle.fill"
            case .high:     return "exclamationmark.circle.fill"
            case .medium:   return "exclamationmark.square.fill"
            case .low:      return "info.circle.fill"
            }
        }
    }
}

// MARK: - Social / Community ---------------------------------------------------

struct Tweet: Identifiable {
    let id        = UUID()
    let username  : String
    let handle    : String
    let content   : String
    let timestamp : Date
    let verified  : Bool
}

// MARK: - Business & Infrastructure -------------------------------------------

struct Business: Identifiable {
    let id           = UUID()
    let name         : String
    let businessType : String
    let riskLevel    : Double                 // 0.0 – 1.0
    let coordinate   : CLLocationCoordinate2D
    let address      : String
    let contactInfo  : String
}

struct Facility: Identifiable {
    let id              = UUID()
    let name            : String
    let type            : String             // e.g. “Hospital”, “Shelter”
    let currentCapacity : Int
    let totalCapacity   : Int
    let coordinate      : CLLocationCoordinate2D
    let address         : String
    let contactInfo     : String
    let services        : [String]
}

// MARK: - Education & Reference ----------------------------------------------

struct SafetyTip: Identifiable {
    let id          = UUID()
    let title       : String
    let description : String
    let iconName    : String
}

struct ResourceContact: Identifiable {
    let id          = UUID()
    let name        : String
    let phoneNumber : String
    let website     : String?
    let category    : String
}

// MARK: - User Role -----------------------------------------------------------

enum UserRole: String, CaseIterable {
    case individual  = "Individual"
    case business    = "Business"
    case cityLeader  = "City Leader"
    
    var icon: String {
        switch self {
        case .individual:  return "person.fill"
        case .business:    return "building.2.fill"
        case .cityLeader:  return "person.3.fill"
        }
    }
    
    var description: String {
        switch self {
        case .individual:  return "Get alerts and safety information for your location"
        case .business:    return "Register your business for emergency coordination"
        case .cityLeader:  return "Monitor and manage emergency responses"
        }
    }
}
