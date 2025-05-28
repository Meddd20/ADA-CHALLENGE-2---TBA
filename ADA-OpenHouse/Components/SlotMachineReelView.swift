//
//  SlotMachineReelView.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 27/05/25.
//

import SwiftUI

struct SlotMachineReelView: View {
    let symbols = [SlotSymbolsModel.cherry.rawValue, SlotSymbolsModel.lemon.rawValue, SlotSymbolsModel.diamond.rawValue, SlotSymbolsModel.seven.rawValue]
    
    let targetSymbol: String
    let stopDelay: Double
    let triggerID: Int
    
    @State private var currentIndex = 0
    @State private var spinTimer: Timer?
    @State private var isSpinning: Bool = false
    @State private var speed: Double = 0.1
    
    var previousSymbols: String {
        symbols[(currentIndex - 1 + symbols.count) % symbols.count]
    }
    
    var currentSymbols: String {
        symbols[currentIndex]
    }
    
    var nextSymbols: String {
        symbols[(currentIndex + 1) % symbols.count]
    }
    
    var body: some View {
        VStack {
            Text(previousSymbols)
                .font(.system(size: 48))
                .opacity(0.3)
                .scaleEffect(0.9)
            
            Text(currentSymbols)
                .font(.system(size: 64, weight: .bold))
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .scaleEffect(1.1)
            
            Text(nextSymbols)
                .font(.system(size: 48))
                .opacity(0.3)
                .scaleEffect(0.9)
        }
        .onDisappear {
            spinTimer?.invalidate()
        }
        .onChange(of: triggerID) {
            startSpin()
        }
    }
    
    func startSpin() {
        isSpinning = true
        speed = 0.05
        spinTimer?.invalidate()
        
        let spinStart = Date()
        let stopTime = spinStart.addingTimeInterval(stopDelay)
        
        func spinStep() {
            currentIndex = (currentIndex + 1) % symbols.count
            
            if Date() >= stopTime && currentSymbols == targetSymbol {
                spinTimer?.invalidate()
                isSpinning = false
            } else {
                spinTimer?.invalidate()
                spinTimer = Timer.scheduledTimer(withTimeInterval: speed, repeats: false) { _ in
                    spinStep()
                }
            }
        }
        spinStep()
    }
}
