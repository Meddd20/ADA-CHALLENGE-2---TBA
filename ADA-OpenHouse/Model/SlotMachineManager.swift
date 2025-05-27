//
//  SlotMachineManager.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 26/05/25.
//

import SwiftUI

class SlotMachineManager: ObservableObject {
    let haptic = HapticModel()
    
    let symbols = SlotSymbolsModel.allSymbols
    var jackpotIn = Int.random(in: 1...5)
    var wasJackpotThisSpin = false
    
    @Published var reelResult = ["🍒", "🍋", "💎"]
    @Published var spinTriggerID = 0
    @Published var jackpotReward: Int? = nil
    @Published var isDoneSpinning = false
    @Published var visibleJackpotReward: Int? = nil
    
    private var spinCount = 0
    
    func startSpin() {
        spinCount += 1
        spinTriggerID += 1
        isDoneSpinning = false
        jackpotReward = nil
        visibleJackpotReward = nil
        isDoneSpinning = false
        
        if spinCount == jackpotIn {
            let jackpotSymbol = symbols.randomElement()!
            reelResult = [jackpotSymbol.rawValue, jackpotSymbol.rawValue, jackpotSymbol.rawValue]
            jackpotReward = jackpotSymbol.jackpotReward
            wasJackpotThisSpin = true
            
            spinCount = 0
            jackpotIn = Int.random(in: 1...5)
            isDoneSpinning = true
            
        } else {
            reelResult = (0..<3).map { _ in symbols.randomElement()!.rawValue }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5 + 1.2 * 2) {
            self.isDoneSpinning = true
            self.visibleJackpotReward = self.jackpotReward
            
            if self.wasJackpotThisSpin {
                self.haptic.playHaptic(duration: 1.0)
                SoundEffect.shared.playSoundEffect(soundEffect: "jackpot")
                self.wasJackpotThisSpin = false
            }
        }
    }
}
