//
//  MapView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI
import MapKit

// MARK: - Lightweight annotation data
/// Wraps the info needed to place a coloured marker on the map.
struct MapAnnotationItem: Identifiable {
    let id         = UUID()
    let coordinate : CLLocationCoordinate2D
    let title      : String
    let severity   : EmergencyAlert.AlertSeverity
}

// MARK: - UIKit‑backed MapKit view
/// Reusable Map component that:
/// • Centres on a binding‑provided coordinate
/// • Accepts an array of `MapAnnotationItem` for coloured pins
/// • Uses `MKMarkerAnnotationView` so we can tint the glyph by alert severity
struct MapView: UIViewRepresentable {
    
    // Where to keep the map centred
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    // Annotations to display (will be redrawn each update)
    let annotations: [MapAnnotationItem]
    
    // -------------------------------------------------------------------------
    // MARK: UIViewRepresentable
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        return map
    }
    
    func updateUIView(_ map: MKMapView, context: Context) {
        // 1. Remove old annotations
        map.removeAnnotations(map.annotations)
        
        // 2. Add fresh ones
        let mkAnnotations = annotations.map { item -> MKPointAnnotation in
            let point = MKPointAnnotation()
            point.coordinate = item.coordinate
            point.title      = item.title
            return point
        }
        map.addAnnotations(mkAnnotations)
        
        // 3. Keep the region centred
        let span   = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        map.setRegion(region, animated: true)
    }
    
    // -------------------------------------------------------------------------
    // MARK: Coordinator for MKMapViewDelegate
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        private let parent: MapView
        init(_ parent: MapView) { self.parent = parent }
        
        func mapView(_ mapView: MKMapView,
                     viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
            
            let id = "AlertMarker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation,
                                              reuseIdentifier: id)
                view?.canShowCallout = true
            } else {
                view?.annotation = annotation
            }
            
            if let marker = view as? MKMarkerAnnotationView,
               let title  = annotation.title ?? "",
               let match  = parent.annotations.first(where: { $0.title == title }) {
                
                marker.markerTintColor = UIColor(match.severity.color)
                marker.glyphImage      = UIImage(systemName: match.severity.icon)
            }
            return view
        }
    }
}

