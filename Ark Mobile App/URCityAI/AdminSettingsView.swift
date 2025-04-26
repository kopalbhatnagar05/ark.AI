//
//  AdminSettingsView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//


//
//  AdminSettingsView.swift
//  URCityAI
//
//  Created on 17/04/25.
//

import SwiftUI
import UniformTypeIdentifiers

/// Advanced settings panel for city leaders / administrators.
struct AdminSettingsView: View {
    
    // ---------------------------------------------------------------------
    // MARK: Settings State (backed by @State for now; wire to persistence later)
    @State private var alertRadius: Double             = 5.0           // miles
    @State private var criticalThreshold: Double       = 1.0           // hours
    @State private var alertExpiryTime: AlertExpiry    = .oneDay
    @State private var enableAutomaticResolve          = true
    
    @State private var enableDataSharing               = true
    @State private var analyticsLevel: AnalyticsLevel  = .anonymous
    
    @State private var enableCommunityPosts            = true
    @State private var approvalRequired                = true
    
    // ---------------------------------------------------------------------
    // MARK: UI State
    @State private var showingLogoutConfirm   = false
    @State private var showingResetConfirm    = false
    @State private var showingSaveConfirm     = false
    @State private var exportingData          = false
    
    // ---------------------------------------------------------------------
    // MARK: Body
    var body: some View {
        NavigationView {
            Form {
                // =========================================================
                // Alert Distribution
                Section(header: Text("Alert Distribution")) {
                    LabeledSlider(
                        title: "Alert Radius",
                        value: $alertRadius,
                        range: 1...20,
                        step: 0.5,
                        unit: "mi"
                    )
                    
                    LabeledSlider(
                        title: "Critical Response Time",
                        value: $criticalThreshold,
                        range: 0.5...4,
                        step: 0.5,
                        unit: "hr"
                    )
                    
                    Picker("Alert Expiry Time", selection: $alertExpiryTime) {
                        ForEach(AlertExpiry.allCases) { Text($0.rawValue).tag($0) }
                    }
                    
                    Toggle("Automatic Alert Resolution", isOn: $enableAutomaticResolve)
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryColor))
                }
                
                // =========================================================
                // Community & Participation
                Section(header: Text("Community")) {
                    Toggle("Enable Community Posts", isOn: $enableCommunityPosts)
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryColor))
                    
                    Toggle("Require Post Approval",
                           isOn: $approvalRequired)
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryColor))
                        .disabled(!enableCommunityPosts)
                }
                
                // =========================================================
                // Data & Privacy
                Section(header: Text("Data & Privacy")) {
                    Toggle("Share Data with Partner Agencies", isOn: $enableDataSharing)
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryColor))
                    
                    Picker("Analytics Collection", selection: $analyticsLevel) {
                        ForEach(AnalyticsLevel.allCases) { Text($0.rawValue).tag($0) }
                    }
                    
                    NavigationLink("Data Retention Policy") {
                        Text("Data retention policy details go here.")
                            .padding()
                    }
                }
                
                // =========================================================
                // Account / Admin Actions
                Section {
                    Button("Export Emergency Data") { exportingData = true }
                        .foregroundColor(AppTheme.primaryColor)
                    
                    Button("Reset to Default Settings") {
                        showingResetConfirm = true
                    }
                    .foregroundColor(.orange)
                    
                    Button("Log Out") {
                        showingLogoutConfirm = true
                    }
                    .foregroundColor(.red)
                }
                
                // =========================================================
                // About
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.1.0").foregroundColor(.secondary)
                    }
                    NavigationLink("Open‑source Licenses") {
                        Text("Display licenses here.")
                            .padding()
                    }
                }
            }
            .navigationBarTitle("Admin Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                saveChanges()
            })
            // -----------------------------------------------------------------
            // Alerts
            .alert(isPresented: $showingResetConfirm) {
                Alert(
                    title: Text("Reset Settings"),
                    message: Text("Restore all admin settings to their defaults?"),
                    primaryButton: .destructive(Text("Reset")) { resetToDefaults() },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showingLogoutConfirm) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        // TODO: inject auth manager & perform sign‑out
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showingSaveConfirm) {
                Alert(title: Text("Settings Saved"),
                      dismissButton: .default(Text("OK")))
            }
            // -----------------------------------------------------------------
            // Data export sheet (dummy placeholder)
            .fileExporter(
                isPresented: $exportingData,
                document: DummyCSV(),
                contentType: .commaSeparatedText,
                defaultFilename: "EmergencyData"
            ) { _ in }
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: Actions
    private func resetToDefaults() {
        // Hard‑coded defaults
        alertRadius            = 5.0
        criticalThreshold      = 1.0
        alertExpiryTime        = .oneDay
        enableAutomaticResolve = true
        
        enableCommunityPosts   = true
        approvalRequired       = true
        
        enableDataSharing      = true
        analyticsLevel         = .anonymous
    }
    
    private func saveChanges() {
        // Plug into persistence later
        showingSaveConfirm = true
    }
}

// ============================================================================
// MARK: - Helper Views & Models
// ============================================================================

/// Slider with a trailing numeric label (“X mi / X hr”)
private struct LabeledSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack {
                Slider(value: $value, in: range, step: step)
                Text("\(value, specifier: "%.1f") \(unit)")
                    .frame(width: 60, alignment: .trailing)
            }
        }
    }
}

// Alert expiry options
enum AlertExpiry: String, CaseIterable, Identifiable {
    case sixHours = "6 Hours"
    case twelveHours = "12 Hours"
    case oneDay = "24 Hours"
    case twoDays = "48 Hours"
    
    var id: String { rawValue }
}

// Privacy / analytics levels
enum AnalyticsLevel: String, CaseIterable, Identifiable {
    case none       = "None"
    case anonymous  = "Anonymous"
    case detailed   = "Detailed"
    
    var id: String { rawValue }
}

// Dummy CSV export document (placeholder for real exporter)
fileprivate struct DummyCSV: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    init() {}
    init(configuration: ReadConfiguration) throws {}
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = "id,title\n1,Placeholder\n".data(using: .utf8) ?? Data()
        return .init(regularFileWithContents: data)
    }
}
