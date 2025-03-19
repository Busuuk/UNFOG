//
//  UNFOGApp.swift
//  UNFOG
//
//  Created by Luigi Donnino on 18/03/25.
//

import SwiftUI

@main
struct UNFOGApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
        
        var body: some Scene {
            WindowGroup {
                if !hasCompletedOnboarding {
                    OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
                } else {
                    // Your main app content view here
                    HomeView()
                }
            }
        }
}
