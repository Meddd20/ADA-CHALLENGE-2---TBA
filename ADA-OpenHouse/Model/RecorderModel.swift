import Foundation
import AVFAudio

class AudioRecorder: ObservableObject {
    var audioRecorder: AVAudioRecorder!
    var timer: Timer?

    @Published var currentLoudness: Float = 0.0 // in dB
    @Published var isTooLoud: Bool = false
    @Published var isRecording: Bool = false

    let loudnessThreshold: Float = -2.5 // Adjust this threshold as needed

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
        isRecording = true
        isTooLoud = false
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.audioRecorder.updateMeters()
            let dB = self.audioRecorder.averagePower(forChannel: 0)
            self.currentLoudness = dB
            print(dB)
            if(dB >= self.loudnessThreshold) {
                self.audioRecorder.stop()
                self.isTooLoud = dB >= self.loudnessThreshold
                self.isRecording = false
            }
        }
    }

    func stopRecording() {
        audioRecorder.stop()
        isRecording = false
        timer?.invalidate()
        isTooLoud = false
    }
}
