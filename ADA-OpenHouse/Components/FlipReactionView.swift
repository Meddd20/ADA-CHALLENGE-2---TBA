//
//  FlipReaction.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 21/05/25.
//

import SwiftUI

struct FlipReactionView: View {
    @StateObject var motion = FlipReactionManager()
    @StateObject private var haptic = HapticModel()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    
    @State private var gameStarted = false
    @State private var showGo = false
    @State private var startTime: Date?
    @State private var reactionTime: Double?
    @State private var isTooEarly = false
    @State private var isPresented = false

    var tagId: String
    var onComplete: (() -> Void)
    let reactionDelay = Double.random(in: 3...6)
    let reactionTreshold = 0.5
    
    var isFastEnough: Bool {
        if let time = reactionTime {
            return time <= reactionTreshold
        }
        return false
    }
    
    var startButtonLabel: String {
        if gameStarted {
            return "Playing..."
        }
        
        if isTooEarly || (reactionTime != nil && !isFastEnough) {
            return "Try Again"
        }
        
        return "Start Now"
    }
    
    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text("🔄 Flip Reaction")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Flip your phone face-down as fast as you can… but only when the screen says GO!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .padding(.top)

            VStack(spacing: 20) {
                if let time = reactionTime {
                    VStack(spacing: 8) {
                        Text(isFastEnough ? "✅ Nice Reflex!" : "⏱ Reaction Time")
                            .font(.headline)
                            .foregroundColor(isFastEnough ? .green : .gray)
                        
                        Text("\(String(format: "%.3f", time)) seconds")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(isFastEnough ? .green : .blue)
                        
                        if !isFastEnough {
                            Text("Try to flip under \(String(format: "%.3f", reactionTreshold))s!")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                } else if isTooEarly {
                    VStack(spacing: 4) {
                        Text("⛔ Too Early!")
                            .font(.title2.bold())
                            .foregroundColor(.red)

                        Text("You moved before the signal. Try again!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else if showGo {
                    Text("GO!")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                        .transition(.scale)
                } else if gameStarted {
                    Text("⏳ Wait for it...")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.orange)
                } else {
                    Text("Tap Start to begin..")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            
            Button(action: {
                if !gameStarted {
                    startGame()
                }
            }) {
                Text(startButtonLabel)
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical, 30)
                    .background(!gameStarted ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 40)
            }
            .disabled(gameStarted ? true : false)
            
            Spacer()
        }
        .onChange(of: motion.isPhoneFaceDown, {
            guard gameStarted else { return }
            
            if motion.isPhoneFaceDown {
                let time = Date().timeIntervalSince(startTime ?? Date())
                
                if let start = startTime {
                    reactionTime = Date().timeIntervalSince(start)
                    gameStarted = false
                    motion.stopDetectFlipReaction()
                } else {
                    isTooEarly = true
                    gameStarted = false
                    motion.stopDetectFlipReaction()
                }
                
                if time <= reactionTreshold {
                   onComplete()
                }
            }
        })
        .onAppear {
            motion.detectFlipReaction()
        }
        .animation(.easeInOut, value: reactionTime)
        .padding()
        .alert(isPresented: $isPresented) {
            Alert(title: Text("Congratulations!"), message: Text("You got it right!"))
        }
    }

    
    func startGame() {
        reactionTime = nil
        isTooEarly = false
        showGo = false
        gameStarted = true
        startTime = nil
        
        motion.detectFlipReaction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reactionDelay) {
            if gameStarted {
                showGo = true
                startTime = Date()
                SoundEffect.shared.playSoundEffect(soundEffect: "go")
            }
        }
    }
}
