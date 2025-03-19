//
//  OnboardingPageView.swift
//  Onboarding
//
//  Created by Francesco Romeo on 16/03/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var selectedBPM: Int = 50
    @Environment(\.sizeCategory) var sizeCategory
    @AppStorage("memoText") private var memoText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Title and description at the top with improved dynamic type support
            VStack(spacing: sizeCategory.isAccessibilityCategory ? 24 : 16) {
                Text(LocalizedStringKey(page.title))
                    .font(.title)
                    .bold()
                    .dynamicTypeSize(.large ... .accessibility5)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .lineSpacing(sizeCategory.isAccessibilityCategory ? 10 : 5)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                
                Text(LocalizedStringKey(page.description))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, sizeCategory.isAccessibilityCategory ? 16 : 32)
                    .foregroundColor(.black)
                    .dynamicTypeSize(.medium ... .accessibility3)
                    .lineSpacing(sizeCategory.isAccessibilityCategory ? 8 : 4)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, sizeCategory.isAccessibilityCategory ? 20 : 40)
            
            // Adaptive spacing
            Spacer(minLength: sizeCategory.isAccessibilityCategory ? 10 : 20)
            
            // MemoAid TextField for the third slide
            if page.isMemoAidSettings {
                VStack(spacing: 15) {
                    Text(LocalizedStringKey("memo_aid_prompt"))
                        .font(.subheadline)
                        .dynamicTypeSize(.medium ... .accessibility2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $memoText)
                        .frame(minHeight: 100, maxHeight: 150)
                        .padding(5)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accent, lineWidth: 3)
                        )
                        .dynamicTypeSize(.medium ... .accessibility2)
                        .focused($isFocused)
                        .onTapGesture {
                            isFocused = true
                        }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .onTapGesture {
                    // Chiude la tastiera quando si clicca fuori dal TextEditor
                    isFocused = false
                }
            }
            
            // Dynamic image sizing based on accessibility needs
            if !page.imageName.isEmpty {
                Image(systemName: page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: imageSize,
                        height: imageSize
                    )
                    .foregroundColor(.accent)
                    .padding(.bottom, sizeCategory.isAccessibilityCategory ? 10 : 20)
                    .accessibilityHidden(true) // Hide from VoiceOver since it's decorative
            }
            
            // Se è la slide del metronomo, mostra i bottoni
            if page.isMetronomeSettings {
                // Per dynamic type elevato, usiamo un layout verticale
                if sizeCategory.isAccessibilityCategory {
                    VStack(spacing: 10) {
                        metronomeButton(text: LocalizedStringKey("slow_button"), bpm: 30)
                        metronomeButton(text: LocalizedStringKey("medium_button"), bpm: 50)
                        metronomeButton(text: LocalizedStringKey("fast_button"), bpm: 79)
                    }
                    .padding(.horizontal)
                } else {
                    // Layout orizzontale per dimensioni normali
                    HStack(spacing: 15) {
                        metronomeButton(text: LocalizedStringKey("slow_button"), bpm: 30)
                        metronomeButton(text: LocalizedStringKey("medium_button"), bpm: 50)
                        metronomeButton(text: LocalizedStringKey("fast_button"), bpm: 79)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Aggiungiamo spazio sufficiente per il bottone di navigazione
            Spacer()
            // Spazio extra per assicurarsi che i bottoni non si sovrappongano al bottone di navigazione
            Color.clear.frame(height: sizeCategory.isAccessibilityCategory ? 150 : 120)
        }
        .padding()
    }
    
    // Dynamic image sizing based on text size
    private var imageSize: CGFloat {
        switch sizeCategory {
        case .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge:
            return 80
        case .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return 60
        default:
            return 120
        }
    }
    
    // Helper function to create uniform buttons
    private func metronomeButton(text: LocalizedStringKey, bpm: Int) -> some View {
        Button(action: { updateBPM(bpm) }) {
            Text(text)
                .font(.body)
                .dynamicTypeSize(.medium ... .accessibility1)
                .padding()
                .frame(
                    minWidth: 90,
                    maxWidth: sizeCategory.isAccessibilityCategory ? .infinity : 110,
                    minHeight: 50,
                    maxHeight: 50
                )
                .background(selectedBPM == bpm ? Color(red: 103/255, green: 58/255, blue: 183/255) : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
    
    private func updateBPM(_ newBPM: Int) {
        selectedBPM = newBPM
    }
}

#Preview {
    OnboardingPageView(page: OnboardingPage(
        title: "voice_guide_title",
        description: "voice_guide_description",
        imageName: "brain.head.profile",
        isMetronomeSettings: false,
        isMemoAidSettings: true
    ))
}


