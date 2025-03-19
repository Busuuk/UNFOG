import SwiftUI
import AVFoundation

struct WatchMetronomeView: View {
    @ObservedObject var sessionManager = WatchSessionManager.shared
    
    // Use the shared group from the watch extension side:
    @AppStorage("bpm", store: UserDefaults(suiteName: "group.Unfog"))
    var bpm: Int = 60
    
    @AppStorage("buttonOrder", store: UserDefaults(suiteName: "group.Unfog"))
    var buttonOrder: String = "metronome,memoaid"
    
    @AppStorage("memoText", store: UserDefaults(suiteName: "group.Unfog"))
    var memoText: String = ""
    
    private let metronome = Metronome()
    @ObservedObject private var memoAidManager = MemoAidManager.shared
    
    @State private var isMetronomePlaying = false
    @State private var isMemoAidPlaying = false
    
    var body: some View {
        VStack(spacing: 30) {
            ForEach(buttonOrder.components(separatedBy: ","), id: \.self) { item in
                if item == "metronome" {
                    rectangularButton(title: "metronome", icon: "metronome", action: toggleMetronome)
                } else if item == "memoaid" {
                    rectangularButton(title: "memoaid", icon: "brain.head.profile", action: toggleMemoAid)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            // Avvia il metronomo con il BPM condiviso
            metronome.startMetronome(bpm: bpm)
            isMetronomePlaying = true
        }
        .onDisappear {
            // Pulizia
            metronome.stopMetronome()
            isMetronomePlaying = false
            memoAidManager.stopMemoText()
            isMemoAidPlaying = false
        }
    }
    
    @ViewBuilder
    private func rectangularButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey(title))
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(10)
            .background(buttonColor(for: icon))
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func buttonColor(for icon: String) -> Color {
        switch icon {
        case "metronome":
            return isMetronomePlaying ? .purple : .gray
        case "brain.head.profile":
            return isMemoAidPlaying ? .purple : .gray
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

#Preview {
    WatchMetronomeView()
}
