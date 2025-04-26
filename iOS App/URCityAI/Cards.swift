//
//  Cards.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI
import CoreLocation    // only for distance calc inside Tweet time‑ago helper

// MARK: - Alert Card ----------------------------------------------------------

struct AlertCardView: View {
    let alert: EmergencyAlert
    
    var body: some View {
        HStack(spacing: 16) {
            // Severity icon
            Image(systemName: alert.severity.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(alert.severity.color)
                .padding(10)
                .background(alert.severity.color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                // Title + badge
                HStack {
                    Text(alert.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(alert.severity.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(alert.severity.color)
                        .cornerRadius(8)
                }
                
                Text(alert.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Time stamp
                HStack {
                    Label(relativeTime(from: alert.timeStamp),
                          systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Facility Status Card -------------------------------------------------

struct FacilityStatusCard: View {
    let facility: Facility
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(facility.name).font(.headline)
                Text(facility.type).font(.subheadline).foregroundColor(.secondary)
                
                HStack {
                    Text("Capacity: \(facility.currentCapacity)/\(facility.totalCapacity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(facility.currentCapacity),
                                 total: Double(facility.totalCapacity))
                        .progressViewStyle(LinearProgressViewStyle(tint: capacityColor))
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(AppTheme.cornerRadius)
    }
    
    private var capacityColor: Color {
        let ratio = Double(facility.currentCapacity) / Double(facility.totalCapacity)
        switch ratio {
        case let x where x > 0.9: return AppTheme.dangerColor
        case let x where x > 0.7: return AppTheme.warningColor
        default:                  return AppTheme.successColor
        }
    }
}

// MARK: - Safety Tip Card ------------------------------------------------------

struct SafetyTipCardView: View {
    let tip: SafetyTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tip.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(AppTheme.primaryColor)
                
                Text(tip.title)
                    .font(.headline)
            }
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .frame(width: 280, height: 160)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(AppTheme.cornerRadius)
    }
}

// MARK: - Tweet Card -----------------------------------------------------------

struct TweetCardView: View {
    let tweet: Tweet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author
            HStack {
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(String(tweet.username.prefix(1)))
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(tweet.username).font(.headline)
                        if tweet.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppTheme.primaryColor)
                                .font(.caption)
                        }
                    }
                    Text(tweet.handle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text(relativeTime(from: tweet.timestamp))
                    .font(.caption).foregroundColor(.secondary)
            }
            // Content
            Text(tweet.content).font(.body)
            
            // Buttons
            HStack {
                Button { /* share */ } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .font(.caption).foregroundColor(.secondary)
                Spacer()
                Button { /* bookmark */ } label: {
                    Image(systemName: "bookmark")
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(AppTheme.cornerRadius)
    }
}

// MARK: - Stat Card (City leader) ---------------------------------------------

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Spacer()
                Text(value).font(.title).fontWeight(.bold).foregroundColor(color)
            }
            Text(title).font(.subheadline).foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(AppTheme.cornerRadius)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Contact Card ---------------------------------------------------------

struct ContactCardView: View {
    let contact: ResourceContact
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name).font(.headline)
                Text(contact.category).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Button {
                if let url = URL(string: "tel:\(contact.phoneNumber.filter { $0.isNumber })") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Image(systemName: "phone.fill")
                    Text(contact.phoneNumber)
                }
                .foregroundColor(AppTheme.primaryColor)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(AppTheme.cornerRadius)
    }
}

// MARK: - Helpers --------------------------------------------------------------

/// Quick human‑readable “time ago” string.
private func relativeTime(from date: Date) -> String {
    let diff = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: .now)
    if let d = diff.day, d > 0 { return d == 1 ? "1d" : "\(d)d" }
    if let h = diff.hour, h > 0 { return h == 1 ? "1h" : "\(h)h" }
    if let m = diff.minute, m > 0 { return m == 1 ? "1m" : "\(m)m" }
    return "now"
}
