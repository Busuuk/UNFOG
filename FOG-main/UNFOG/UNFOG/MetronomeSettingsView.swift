import SwiftUI

struct MetronomeSettingsView: View {
    // If you want to synchronize BPM with your iPhone–Watch session manager:
    @ObservedObject var sessionManager = WatchSessionManager.shared
    
    // If you prefer direct @AppStorage for BPM (reading/writing from the shared container):
    // @AppStorage("bpm", store: UserDefaults(suiteName: "group.com.example.FOG"))
    // private var bpm: Int = 50

    @State private var waveAmplitude: CGFloat = 10.0

    var body: some View {
        VStack {
            Spacer()

            Text("Imposta Velocità")
                .font(.title)
                .padding(.top, 40)

            Spacer()

            // Purple sound bar animation
            SoundBarView(amplitude: waveAmplitude, color: .purple)
                .frame(height: 100)
                .padding()

            Spacer()

            HStack(spacing: 40) {
                Button(action: { updateBPM(30, amplitude: 5) }) {
                    Text("Slow")
                        .padding()
                        .frame(width: 80)
                        .background(sessionManager.bpm == 30
                                    ? Color(red: 103/255, green: 58/255, blue: 183/255)
                                    : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: { updateBPM(50, amplitude: 10) }) {
                    Text("Medium")
                        .padding(10)
                        .frame(width: 85, height: 55)
                        .background(sessionManager.bpm == 50
                                    ? Color(red: 103/255, green: 58/255, blue: 183/255)
                                    : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: { updateBPM(79, amplitude: 20) }) {
                    Text("Fast")
                        .padding()
                        .frame(width: 80)
                        .background(sessionManager.bpm == 79
                                    ? Color(red: 103/255, green: 58/255, blue: 183/255)
                                    : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()

            Button("Salva") {
                sendBPMToWatch()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }

    /// Sets the BPM and also changes the wave amplitude for the animated sound bar.
    private func updateBPM(_ newBPM: Int, amplitude: CGFloat) {
        sessionManager.bpm = newBPM
        waveAmplitude = amplitude
        sendBPMToWatch()
    }

    /// Example function for sending BPM to the watch immediately (if reachable).
    private func sendBPMToWatch() {
        print("📤 Invio BPM a Watch: \(sessionManager.bpm)")
        sessionManager.sendBPMToWatch()
    }
}

struct SoundBarView: View {
    var amplitude: CGFloat
    var color: Color = .purple  // Purple color for the waveform bars

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<10, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 10, height: CGFloat.random(in: 10...(amplitude * 5)))
                    .foregroundColor(color)
                    // Animates the random heights
                    .animation(
                        Animation.easeInOut(duration: 0.3).repeatForever(),
                        value: amplitude
                    )
            }
        }
        .frame(height: 50)
    }
}

