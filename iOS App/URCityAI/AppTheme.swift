//
//  AppTheme.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// Central colour & sizing palette for ark.AI.
/// Keep all hard‑coded styling here so you can theme the whole app quickly.
struct AppTheme {
    static let primaryColor  = Color(red: 0.20, green: 0.50, blue: 0.90)   // Blue
    static let dangerColor   = Color(red: 0.80, green: 0.20, blue: 0.20)   // Red
    static let warningColor  = Color(red: 0.90, green: 0.70, blue: 0.20)   // Amber
    static let successColor  = Color(red: 0.20, green: 0.70, blue: 0.40)   // Green
    
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 4
}
