import SwiftUI

/// Top‑level scene graph for ark.AI.
/// Handles splash screen, role selection, and routing to role‑specific dashboards.
@main
struct URCityAIApp: App {
    
    // Global user preferences
    @StateObject private var userPreferences = UserPreferences()
    
    // Persisted / in‑memory state
    @State private var selectedRole: UserRole? = nil
    @State private var isShowingSplash         = true
    
    // -------------------------------------------------------------------------
    // Scene
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingSplash {
                    SplashScreenView()
                        .onAppear(perform: handleLaunch)
                } else {
                    // MAIN FLOW
                    if let role = selectedRole {
                        switch role {
                        case .individual:
                            IndividualDashboardView(selectedRole: $selectedRole)
                                .environmentObject(userPreferences)
                        case .business:
                            BusinessFormView(selectedRole: $selectedRole)
                                .environmentObject(userPreferences)
                        case .cityLeader:
                            CityLeaderDashboardView(selectedRole: $selectedRole)
                                .environmentObject(userPreferences)
                        }
                    } else {
                        RoleSelectionView(selectedRole: $selectedRole)
                    }
                }
            }
            .preferredColorScheme(userPreferences.darkModeEnabled ? .dark : .light)
        }
    }
    
    // -------------------------------------------------------------------------
    // Launch helper – loads saved role, hides splash after delay
    private func handleLaunch() {
        // Retrieve previously selected role, if any
        if let saved = UserDefaults.standard.string(forKey: "userRole"),
           let role  = UserRole(rawValue: saved) {
            selectedRole = role
        }
        // Hide splash after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.5)) {
                isShowingSplash = false
            }
        }
    }
}

