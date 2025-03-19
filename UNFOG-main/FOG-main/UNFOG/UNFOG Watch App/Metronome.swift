import WatchKit
import AVFoundation

class Metronome {
    var timer: Timer?
    let speechSynthesizer = AVSpeechSynthesizer()

    func startMetronome(bpm: Int) {
        stopMetronome()

        let interval = 60.0 / Double(bpm)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
           self.playHapticFeedback()
        }
    }

    func stopMetronome() {
        timer?.invalidate()
        timer = nil
    }

    private func playHapticFeedback() {
        DispatchQueue.global(qos: .userInitiated).async {
            WKInterfaceDevice.current().play(.notification) // Vibrazione forte
        }

        }
    }
