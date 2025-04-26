//
//  FacilityCardView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


import SwiftUI

struct FacilityCardView: View {
    let facility: Facility
    
    private var capacityColor: Color {
        let pct = Double(facility.currentCapacity) / Double(facility.totalCapacity)
        switch pct {
        case let x where x > 0.9: return AppTheme.dangerColor
        case let x where x > 0.7: return AppTheme.warningColor
        default:                  return AppTheme.successColor
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: facility.type == "Hospital" ? "cross.fill"
                                                              : "house.fill")
                    .foregroundColor(facility.type == "Hospital" ? .red
                                                                 : AppTheme.primaryColor)
                    .font(.title3)
                
                Spacer()
                
                Text("\(facility.currentCapacity)/\(facility.totalCapacity)")
                    .font(.caption)
                    .padding(6)
                    .background(capacityColor.opacity(0.2))
                    .foregroundColor(capacityColor)
                    .cornerRadius(8)
            }
            
            Text(facility.name).font(.headline)
            Text(facility.address)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            Text(facility.contactInfo)
                .font(.caption)
                .foregroundColor(AppTheme.primaryColor)
        }
        .padding()
        .frame(width: 240, height: 160)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(AppTheme.cornerRadius)
    }
}
