//
//  SplashScreenView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// First screen users see while the app initialises.
/// Shows a pulsating bell icon, ark.AI branding, and tagline.
struct SplashScreenView: View {
    @State private var pulsate = false
    
    var body: some View {
        ZStack {
            // Subtle blue‑tinted gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    AppTheme.primaryColor.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "bell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(AppTheme.primaryColor)
                    .scaleEffect(pulsate ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: pulsate
                    )
                    .onAppear { pulsate = true }
                
                // Brand
                Text("ark.AI")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryColor)
                
                Text("Real‑time Emergency Alerts")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.top, -10)
                
                Text("Stay Safe. Stay Informed.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
