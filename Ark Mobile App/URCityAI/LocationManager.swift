//
//  LocationManager.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import Foundation
import CoreLocation
import Combine

/// Publishes the user’s current location and permission status.
/// Remember to add the relevant keys to Info.plist:
///  - NSLocationWhenInUseUsageDescription
///  - (optionally) NSLocationAlwaysAndWhenInUseUsageDescription
final class LocationManager: NSObject, ObservableObject {
    
    // MARK: Published properties
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: Private
    private let locationManager = CLLocationManager()
    
    // MARK: Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: Public helpers
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async { self.authorizationStatus = status }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.first else { return }
        DispatchQueue.main.async { self.location = latest }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 Location error: \(error.localizedDescription)")
    }
}
