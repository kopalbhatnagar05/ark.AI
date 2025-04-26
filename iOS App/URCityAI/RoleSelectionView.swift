//
//  RoleSelectionView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// On‑boarding screen where the user selects their role
/// (Individual • Business • City Leader) before entering the app.
struct RoleSelectionView: View {
    
    /// Propagates the chosen role up to `EmergencyAlertApp`
    @Binding var selectedRole: UserRole?
    
    /// Currently highlighted card index
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        ZStack {
            // Gentle background tint
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    AppTheme.primaryColor.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Brand
                Text("ark.AI")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryColor)
                
                Text("Select Your Role")
                    .font(.title2)
                    .fontWeight(.medium)
                
                // Role cards
                VStack(spacing: 16) {
                    ForEach(Array(UserRole.allCases.enumerated()),
                            id: \.element) { index, role in
                        RoleCardNew(
                            role: role,
                            isSelected: selectedIndex == index
                        ) {
                            withAnimation(.spring()) { selectedIndex = index }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Continue button
                Button {
                    if let index = selectedIndex {
                        let role = UserRole.allCases[index]
                        selectedRole = role
                        // Persist selection
                        UserDefaults.standard.set(role.rawValue, forKey: "userRole")
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedIndex != nil
                                    ? AppTheme.primaryColor
                                    : Color.gray)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(radius: selectedIndex != nil ? 3 : 0)
                }
                .disabled(selectedIndex == nil)
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .padding(.vertical, 50)
        }
    }
}

// MARK: - Role Card -----------------------------------------------------------

struct RoleCardNew: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon bubble
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.primaryColor
                                     : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: role.icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isSelected ? .white : .gray)
                    .frame(width: 30, height: 30)
            }
            
            // Labels
            VStack(alignment: .leading, spacing: 4) {
                Text(role.rawValue).font(.headline)
                Text(role.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Radio indicator
            ZStack {
                Circle()
                    .stroke(isSelected ? AppTheme.primaryColor
                                       : Color.gray.opacity(0.3),
                            lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .fill(AppTheme.primaryColor)
                        .frame(width: 16, height: 16)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: isSelected
                        ? AppTheme.primaryColor.opacity(0.3)
                        : Color.clear,
                        radius: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(isSelected ? AppTheme.primaryColor : Color.clear,
                        lineWidth: 2)
        )
        .onTapGesture(perform: action)
    }
}
