//
//  BackSound.swift
//  iTour
//
//  Created by Medhiko Biraja on 27/05/25.
//

import AVFoundation

class BackgroundMusicPlayer {
    static let shared = BackgroundMusicPlayer()
    var player: AVAudioPlayer?
    
    func play(backsound: String) {
        AudioSessionManager.configurePlaybackSession()
        
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
    
    
    
    
}
