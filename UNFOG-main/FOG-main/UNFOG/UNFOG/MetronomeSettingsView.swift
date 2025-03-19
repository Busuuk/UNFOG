import SwiftUI

struct MetronomeSettingsView: View {
    @ObservedObject var sessionManager = WatchSessionManager.shared
    @State private var waveAmplitude: CGFloat = 10.0
    @State private var showSavedAlert = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Text(LocalizedStringKey("metronome"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                
                Text(LocalizedStringKey("chooselevel"))
                    .foregroundStyle(.secondary)
                    
                Spacer()
                
                SoundBarView(amplitude: waveAmplitude, color: .purple)
                    .frame(height: 100)
                    .padding()
                    .shadow(radius: 5)
                
                Spacer()
                
                HStack(spacing: 40) {
                    speedButton(title: "LV1", bpm: 30, amplitude: 5)
                    speedButton(title: "LV2", bpm: 50, amplitude: 10)
                    speedButton(title: "LV3", bpm: 79, amplitude: 20)
                }
                .padding()
                
                Button(action: {
                    sendBPMToWatch()
                    showSavedAlert = true
                }) {
                    Text(LocalizedStringKey("save"))
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.horizontal, 30)
                }
                .alert(isPresented: $showSavedAlert) {
                    Alert(title: Text(LocalizedStringKey("salvato")), message: Text(LocalizedStringKey("speedtext")), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func updateBPM(_ newBPM: Int, amplitude: CGFloat) {
        sessionManager.bpm = newBPM
        waveAmplitude = amplitude
        sendBPMToWatch()
    }
    
    private func sendBPMToWatch() {
        print("📤 Invio BPM a Watch: \(sessionManager.bpm)")
        sessionManager.sendBPMToWatch()
    }
    
    private func speedButton(title: String, bpm: Int, amplitude: CGFloat) -> some View {
        Button(action: { updateBPM(bpm, amplitude: amplitude) }) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(width: 85, height: 55)
                .background(sessionManager.bpm == bpm ? Color.purple : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
        }
    }
}

struct SoundBarView: View {
    var amplitude: CGFloat
    var color: Color = .purple
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<10, id: \ .self) { _ in
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 10, height: CGFloat.random(in: 10...(amplitude * 5)))
                    .foregroundColor(color)
                    .animation(Animation.easeInOut(duration: 0.3).repeatForever(), value: amplitude)
            }
        }
        .frame(height: 50)
    }
}

#Preview {
   MetronomeSettingsView()
}
