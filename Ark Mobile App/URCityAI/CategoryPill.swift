//
//  CategoryPill.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// Compact “chip” used for filtering lists (e.g. emergency‑contact categories).
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    var color: Color = AppTheme.primaryColor        // ← new default
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color
                                      : Color(UIColor.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

