//
//  ShareSheet.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// UIKit wrapper for the standard iOS share‑sheet.
/// Pass any `[Any]` (text, URLs, images, etc.).
struct ShareSheet: UIViewControllerRepresentable {
    
    let items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    // -------------------------------------------------------------------------
    // MARK: UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items,
                                                  applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: Context) {
        // Nothing to update dynamically
    }
}
