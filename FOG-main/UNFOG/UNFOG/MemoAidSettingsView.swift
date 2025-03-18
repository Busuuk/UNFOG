import SwiftUI
import WatchConnectivity

struct MemoAidSettingsView: View {
    // Use shared store with suiteName
    @AppStorage("memoText", store: UserDefaults(suiteName: "group.com.unfogg"))
    private var memoText: String = ""
    
    private let session = WCSession.default

    var body: some View {
        VStack(spacing: 20) {
            Text("Write everything you want to hear when the memo aid tip is used")
                .font(.body)
                .padding(.horizontal)

            TextEditor(text: $memoText)
                .padding()
                .frame(maxWidth: 350, minHeight: 150)
                .cornerRadius(8)
                .border(Color.gray, width: 1)

            Button("Save & Send to Watch") {
                sendToWatch()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .navigationTitle("Memo Aid Settings")
    }
    
    private func sendToWatch() {
        guard session.activationState == .activated else {
            print("❌ WCSession not activated on iPhone")
            return
        }
        
        let dataToSend = ["memoText": memoText]
        if session.isReachable {
            session.sendMessage(dataToSend, replyHandler: nil, errorHandler: { error in
                print("❌ Error sending memo text: \(error.localizedDescription)")
            })
        } else {
            do {
                try session.updateApplicationContext(dataToSend)
                print("✅ Memo text sent via updateApplicationContext")
            } catch {
                print("❌ Error updating app context: \(error)")
            }
        }
    }
}

