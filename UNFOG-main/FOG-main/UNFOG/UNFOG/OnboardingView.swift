//
//  OnboardingView.swift
//  Onboarding
//
//  Created by Francesco Romeo on 16/03/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool
    @Environment(\.sizeCategory) var sizeCategory
    
    let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            title: "motor_assistant_title",
            description: "motor_assistant_description",
            imageName: "figure.walk",
            isMetronomeSettings: false,
            isMemoAidSettings: false
        ),
        OnboardingPage(
            title: "metronome_title",
            description: "metronome_description",
            imageName: "metronome",
            isMetronomeSettings: true,
            isMemoAidSettings: false
        ),
        OnboardingPage(
            title: "voice_guide_title",
            description: "voice_guide_description",
            imageName: "brain.head.profile",
            isMetronomeSettings: false,
            isMemoAidSettings: true
        )
    ]
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(onboardingPages.indices, id: \.self) { index in
                OnboardingPageView(page: onboardingPages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        
        .overlay(
            Button(action: {
                if currentPage == onboardingPages.count - 1 {
                    isOnboardingComplete = true
                } else {
                    currentPage += 1
                }
            }) {
                Text(currentPage == onboardingPages.count - 1 ? LocalizedStringKey("get_started_button") : LocalizedStringKey("next_button"))
                    .font(.headline)
                    .dynamicTypeSize(.medium ... .accessibility2)
                    .foregroundColor(.white)
                    .padding(.horizontal, sizeCategory.isAccessibilityCategory ? 24 : 16)
                    .padding(.vertical, sizeCategory.isAccessibilityCategory ? 16 : 12)
                    .frame(
                        minWidth: sizeCategory.isAccessibilityCategory ? 220 : 200,
                        maxWidth: sizeCategory.isAccessibilityCategory ? 300 : 220,
                        minHeight: sizeCategory.isAccessibilityCategory ? 60 : 50
                    )
                    .background(Color.accentColor1)
                    .cornerRadius(25)
            }
            .padding(.bottom, sizeCategory.isAccessibilityCategory ? 60 : 50),
            alignment: .bottom
        )
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
