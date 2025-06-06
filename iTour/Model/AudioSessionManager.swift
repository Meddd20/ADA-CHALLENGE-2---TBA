//
//  AudioManager.swift
//  iTour
//
//  Created by Medhiko Biraja on 01/06/25.
//

import AVFoundation

class AudioSessionManager {
    static func configurePlaybackSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Audio session setup failed: \(error.localizedDescription)")
        }
    }
}
