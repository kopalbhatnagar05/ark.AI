//
//  LocationStatusBar.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI
import CoreLocation

/// Top‑of‑dashboard bar that shows whether live‑location tracking is on
/// and lets the user toggle it. If permission is missing, it shows an alert
/// (the alert handling is driven by the binding in the parent view).
struct LocationStatusBar: View {
    
    // Whether the toggle is on
    @Binding var isLiveLocationEnabled: Bool
    
    // Shared location manager
    @ObservedObject var locationManager: LocationManager
    
    // Controls “open settings” alert in parent
    @Binding var showingNoPermissionAlert: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isLiveLocationEnabled ? "location.fill"
                                                    : "location.slash.fill")
                .foregroundColor(isLiveLocationEnabled
                                 ? AppTheme.successColor
                                 : .gray)
            
            Text(isLiveLocationEnabled ? "Live Location Active"
                                       : "Live Location Disabled")
                .font(.subheadline)
                .foregroundColor(isLiveLocationEnabled
                                 ? AppTheme.successColor
                                 : .gray)
            
            Spacer()
            
            Toggle("", isOn: $isLiveLocationEnabled)
                .labelsHidden()
                .onChange(of: isLiveLocationEnabled) { newValue in
                    guard newValue else { return }
                    // If permission is not granted, reset toggle and prompt user
                    if locationManager.authorizationStatus != .authorizedWhenInUse &&
                       locationManager.authorizationStatus != .authorizedAlways {
                        isLiveLocationEnabled = false
                        showingNoPermissionAlert = true
                    }
                }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(AppTheme.cornerRadius)
    }
}
