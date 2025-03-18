import SwiftUI
import WatchConnectivity
import AVFoundation

class MemoAidManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = MemoAidManager()
    
    private let speechSynth = AVSpeechSynthesizer()
    
    // Optionally read from app group. If you prefer
    // to rely on WatchSessionManager alone, you can remove this:
    @Published var memoText: String = UserDefaults(suiteName: "group.UNFOG.sharedData")?
        .string(forKey: "memoText") ?? ""
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func playMemoText() {
        guard !memoText.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: memoText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynth.speak(utterance)
    }

    func stopMemoText() {
        speechSynth.stopSpeaking(at: .immediate)
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("Errore di attivazione WCSession: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let text = message["memoText"] as? String {
            DispatchQueue.main.async {
                self.memoText = text
                // Also store to the shared defaults if desired:
                UserDefaults(suiteName: "group.UNFOG.sharedData")?.set(text, forKey: "memoText")
            }
        }
    }
}

