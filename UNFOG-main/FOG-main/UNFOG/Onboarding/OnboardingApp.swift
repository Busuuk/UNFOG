//
//  OnboardingApp.swift
//  Onboarding
//
//  Created by Francesco Romeo on 16/03/25.
//

import SwiftUI

@main
struct OnboardingApp: App {
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
