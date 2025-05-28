//
//  BackSound.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 27/05/25.
//

import AVFoundation

class BackgroundMusicPlayer {
    static let shared = BackgroundMusicPlayer()
    var player: AVAudioPlayer?
    
    func play(backsound: String) {
        prepareAudioSession()
        
        guard let url = Bundle.main.url(forResource: backsound, withExtension: "mp3") else { return }
        
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1
            newPlayer.volume = 0.4
            newPlayer.play()
            player = newPlayer
        } catch {
            print("🎵 Failed to play: \(error)")
        }

    }
    
    func stop() {
        player?.stop()
        player = nil
    }
    
    func prepareAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    
}
