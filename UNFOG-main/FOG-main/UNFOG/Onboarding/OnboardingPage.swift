//
//  OnboardingPage.swift
//  Onboarding
//
//  Created by Francesco Romeo on 16/03/25.
//

import SwiftUI


struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let isMetronomeSettings: Bool
    let isMemoAidSettings: Bool
    
    // Aggiungiamo un initializer per comodità
    init(title: String, description: String, imageName: String, isMetronomeSettings: Bool = false, isMemoAidSettings: Bool = false) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.isMetronomeSettings = isMetronomeSettings
        self.isMemoAidSettings = isMemoAidSettings
    }
}


