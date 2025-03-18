import SwiftUI
import AVFoundation

struct WatchMetronomeView: View {
    @ObservedObject var sessionManager = WatchSessionManager.shared
    
    // Use the shared group from the watch extension side:
    @AppStorage("bpm", store: UserDefaults(suiteName: "group.UNFOG.sharedData"))
    var bpm: Int = 60
    
    @AppStorage("buttonOrder", store: UserDefaults(suiteName: "group.UNFOG.sharedData"))
    var buttonOrder: String = "Metronome,Memo Aid"
    
    @AppStorage("memoText", store: UserDefaults(suiteName: "group.UNFOG.sharedData"))
    var memoText: String = ""
    
    private let metronome = Metronome()
    @ObservedObject private var memoAidManager = MemoAidManager.shared
    
    @State private var isMetronomePlaying = false
    @State private var isMemoAidPlaying = false

    var body: some View {
        VStack {
            // Build the UI based on the shared “buttonOrder”
            ForEach(buttonOrder.components(separatedBy: ","), id: \.self) { item in
                if item == "Metronome" {
                    expandableButton(title: "Metronome", icon: "music.quarternote.3") {
                        toggleMetronome()
                    }
                } else if item == "Memo Aid" {
                    expandableButton(title: "Memo Aid", icon: "brain.head.profile") {
                        toggleMemoAid()
                    }
                }
            }
        }
        .onAppear {
            // Start the metronome with the shared BPM
            metronome.startMetronome(bpm: bpm)
            isMetronomePlaying = true
        }
        .onDisappear {
            // Clean up
            metronome.stopMetronome()
            isMetronomePlaying = false
            memoAidManager.stopMemoText()
            isMemoAidPlaying = false
        }
    }
    
    @ViewBuilder
    private func expandableButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)
                    .padding(.leading, 10)
                
                Spacer()
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(.trailing, 10)
            }
            .frame(width: 140, height: 50)
            .background(buttonColor(for: title))
            .cornerRadius(10)
            .shadow(radius: 3)
        }
    }
    
    private func buttonColor(for title: String) -> Color {
        switch title {
        case "Metronome":
            return isMetronomePlaying ? .red : .gray
        case "Memo Aid":
            return isMemoAidPlaying ? .blue : .gray
        default:
            return .gray
        }
    }

    private func toggleMetronome() {
        if isMetronomePlaying {
            metronome.stopMetronome()
            isMetronomePlaying = false
        } else {
            if isMemoAidPlaying {
                memoAidManager.stopMemoText()
                isMemoAidPlaying = false
            }
            metronome.startMetronome(bpm: bpm)
            isMetronomePlaying = true
        }
    }

    private func toggleMemoAid() {
        if isMemoAidPlaying {
            memoAidManager.stopMemoText()
            isMemoAidPlaying = false
        } else {
            if isMetronomePlaying {
                metronome.stopMetronome()
                isMetronomePlaying = false
            }
            memoAidManager.playMemoText()
            isMemoAidPlaying = true
        }
    }
}

