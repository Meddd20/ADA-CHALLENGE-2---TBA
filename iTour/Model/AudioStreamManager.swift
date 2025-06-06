//
//  AudioStreamManager.swift
//  iTour
//
//  Created by Medhiko Biraja on 31/05/25.
//

import Foundation
import AVFoundation
import Combine

class AudioStreamManager: ObservableObject {
    private let audioEngine = AVAudioEngine()
    
    @Published var currentVolume: CGFloat = 0.01
    let audioPublisher = PassthroughSubject<(AVAudioPCMBuffer, AVAudioTime), Never>()
    
    var audioFormat: AVAudioFormat {
        return audioEngine.inputNode.inputFormat(forBus: 0)
    }
    
    func start() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
            try session.setActive(true)
            

            let inputNode = audioEngine.inputNode
            let inputFormat = inputNode.inputFormat(forBus: 0)

            // 🔐 Defensive check
            guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
                print("❌ Invalid input format: sampleRate = \(inputFormat.sampleRate), channelCount = \(inputFormat.channelCount)")
                return
            }

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, time in
                self.audioPublisher.send((buffer, time))

                guard let channelData = buffer.floatChannelData?[0] else { return }

                let frameLength = Int(buffer.frameLength)
                let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
                let rms = sqrt(samples.map { $0 * $0 }.reduce(0, +) / Float(frameLength))
                let normalized = max(0.01, min(1.0, rms * 10))

                DispatchQueue.main.async {
                    self.currentVolume = CGFloat(normalized)
                }
            }

            try audioEngine.start()
            print("🎤 Mic listening started.")

        } catch {
            print("🚫 Error starting mic: \(error.localizedDescription)")
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        print("🛑 Mic stopped.")
    }
}


