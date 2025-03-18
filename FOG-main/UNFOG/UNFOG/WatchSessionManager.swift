import WatchConnectivity
import SwiftUI

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    static let shared = WatchSessionManager()
    
    // For the shared container:
    private let sharedDefaults = UserDefaults(suiteName: "group.UNFOG.sharedData") ?? .standard
    
    @Published var buttonOrder: String {
        didSet {
            sharedDefaults.set(buttonOrder, forKey: "buttonOrder")
            sendButtonOrderToWatch()
        }
    }
    
    @Published var bpm: Int {
        didSet {
            sharedDefaults.set(bpm, forKey: "bpm")
            sendBPMToWatch()
        }
    }
    
    @Published var memoText: String {
        didSet {
            sharedDefaults.set(memoText, forKey: "memoText")
            sendMemoTextToWatch()
        }
    }

    private override init() {
        // Read initial values from the shared container
        let defaultOrder = "Metronome,Memo Aid"
        let storedOrder = sharedDefaults.string(forKey: "buttonOrder") ?? defaultOrder
        let storedBPM = sharedDefaults.integer(forKey: "bpm")
        let storedMemo = sharedDefaults.string(forKey: "memoText") ?? ""
        
        self.buttonOrder = storedOrder
        self.bpm = storedBPM
        self.memoText = storedMemo
        
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendButtonOrderToWatch() {
        guard WCSession.default.activationState == .activated else {
            print("❌ WCSession not active on Watch")
            return
        }
        print("📤 Sending button order: \(buttonOrder)")
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["buttonOrder": buttonOrder],
                                          replyHandler: nil,
                                          errorHandler: { error in
                print("❌ Error sending button order: \(error.localizedDescription)")
            })
        } else {
            do {
                try WCSession.default.updateApplicationContext(["buttonOrder": buttonOrder])
                print("✅ Button order sent via updateApplicationContext")
            } catch {
                print("❌ Error updating application context: \(error)")
            }
        }
    }
    
    func sendBPMToWatch() {
        guard WCSession.default.activationState == .activated else {
            print("❌ WCSession not active on Watch")
            return
        }
        print("📤 Sending BPM: \(bpm)")
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["bpm": bpm],
                                          replyHandler: nil,
                                          errorHandler: { error in
                print("❌ Error sending BPM: \(error.localizedDescription)")
            })
        } else {
            do {
                try WCSession.default.updateApplicationContext(["bpm": bpm])
                print("✅ BPM sent via updateApplicationContext")
            } catch {
                print("❌ Error updating application context: \(error)")
            }
        }
    }
    
    func sendMemoTextToWatch() {
        guard WCSession.default.activationState == .activated else {
            print("❌ WCSession not active on Watch")
            return
        }
        print("📤 Sending memo text: \(memoText)")
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["memoText": memoText],
                                          replyHandler: nil,
                                          errorHandler: { error in
                print("❌ Error sending memo text: \(error.localizedDescription)")
            })
        } else {
            do {
                try WCSession.default.updateApplicationContext(["memoText": memoText])
                print("✅ Memo text sent via updateApplicationContext")
            } catch {
                print("❌ Error updating application context: \(error)")
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {
        if let error = error {
            print("❌ WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("✅ WCSession activated successfully")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let receivedBPM = message["bpm"] as? Int {
                print("📩 Received BPM: \(receivedBPM)")
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
