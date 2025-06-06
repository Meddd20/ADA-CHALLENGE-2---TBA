import Foundation
import AVFAudio

class AudioRecorder: ObservableObject {
    var audioRecorder: AVAudioRecorder!
    var timer: Timer?

    @Published var currentLoudness: Float = 0.0 // in dB
    @Published var isTooLoud: Bool = false
    @Published var isRecording: Bool = false

    let loudnessThreshold: Float = -5 // Adjust this threshold as needed

    init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let settings = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ] as [String : Any]

            let url = URL(fileURLWithPath: "/dev/null")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.isMeteringEnabled = true
        } catch {
            print("Audio session error: \(error)")
        }
    }

    func startRecording() {
        audioRecorder.record()
        currentLoudness = 0.0
        isRecording = true
        isTooLoud = false
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.audioRecorder.updateMeters()
            let dB = self.audioRecorder.averagePower(forChannel: 0)
            if(loudnessHeight(from: dB, treshold: self.loudnessThreshold)) > 0 {
                self.currentLoudness = dB
            }
            if(dB >= self.loudnessThreshold) {
                self.audioRecorder.stop()
                self.isRecording = false
                self.isTooLoud = true
            }
        }
    }

    func stopRecording() {
        audioRecorder.stop()
        isRecording = false
        timer?.invalidate()
        isTooLoud = false
        currentLoudness = 0.0
    }
}

func loudnessHeight(from dB: Float, treshold: Float) -> CGFloat {
    // Normalize: -40 to [treshhold] dB mapped to 0–100
    let normalized = max(0, min(1, (dB + 40) / (40 + treshold)))
    return CGFloat(normalized) * 100
}
