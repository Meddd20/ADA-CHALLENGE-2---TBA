//
//  SoundEffect.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 21/05/25.
//

import AVFoundation
import SwiftUI

class SoundEffect {
    static let shared = SoundEffect()
    private var audioPlayer: AVAudioPlayer?
    
    func playStartSound() {
        guard let soundURL = Bundle.main.url(forResource: "go", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}
