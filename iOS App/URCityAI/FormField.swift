//
//  FormField.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// Reusable single‑line text (or secure) input used across registration,
/// profile‑edit, business forms, etc.
struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
        }
    }
}
