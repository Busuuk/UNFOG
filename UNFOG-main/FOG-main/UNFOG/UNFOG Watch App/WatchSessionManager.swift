import WatchConnectivity
import SwiftUI

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    
    private let sharedDefaults = UserDefaults(suiteName: "group.Unfog") ?? .standard
    
    @Published var bpm: Int {
        didSet {
            sharedDefaults.set(bpm, forKey: "bpm")
            print("📥 BPM updated on Watch: \(bpm)")
        }
    }
    
    @Published var buttonOrder: String {
        didSet {
            sharedDefaults.set(buttonOrder, forKey: "buttonOrder")
            print("📥 Button order updated on Watch: \(buttonOrder)")
        }
    }
    
    @Published var memoText: String {
        didSet {
            sharedDefaults.set(memoText, forKey: "memoText")
            print("📥 Memo text updated on Watch: \(memoText)")
        }
    }
    
    private override init() {
        // Initialize from the shared defaults
        let storedBPM = sharedDefaults.integer(forKey: "bpm")
        let storedOrder = sharedDefaults.string(forKey: "buttonOrder") ?? "Metronome,Memo Aid"
        let storedMemo = sharedDefaults.string(forKey: "memoText") ?? ""
        
        self.bpm = storedBPM
        self.buttonOrder = storedOrder
        self.memoText = storedMemo
        
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("❌ WCSession activation failed on Watch: \(error.localizedDescription)")
        } else {
            print("✅ WCSession activated on Watch")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let receivedBPM = message["bpm"] as? Int {
                print("📩 Received BPM via sendMessage: \(receivedBPM)")
                self.bpm = receivedBPM
            }
            if let receivedOrder = message["buttonOrder"] as? String {
                print("📩 Received button order: \(receivedOrder)")
                self.buttonOrder = receivedOrder
            }
            if let receivedMemoText = message["memoText"] as? String {
                print("📩 Received memo text: \(receivedMemoText)")
                self.memoText = receivedMemoText
            }
        }
    }
    
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let receivedBPM = applicationContext["bpm"] as? Int {
                print("📩 Received BPM via updateApplicationContext: \(receivedBPM)")
                self.bpm = receivedBPM
            }
            if let receivedOrder = applicationContext["buttonOrder"] as? String {
                print("📩 Received button order via updateApplicationContext: \(receivedOrder)")
                self.buttonOrder = receivedOrder
            }
            if let receivedMemoText = applicationContext["memoText"] as? String {
                print("📩 Received memo text via updateApplicationContext: \(receivedMemoText)")
                self.memoText = receivedMemoText
            }
        }
    }
}
