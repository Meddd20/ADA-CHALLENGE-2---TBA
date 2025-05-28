//
//  SlotMachineView.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 27/05/25.
//

import SwiftUI

struct SlotMachineView: View {
    @StateObject var manager = SlotMachineManager()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    let baseSpinTime = 3.5
    
    var tagId: String

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.red.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Text("SLOT MACHINE")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.yellow)
                .padding(.top, 20)
                .shadow(color: .red.opacity(0.8), radius: 10, x: 0, y: 5)
                
                VStack() {
                    if let reward = manager.visibleJackpotReward {
                        Text("✨ JACKPOT! ✨")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .orange, radius: 10)
                            .transition(.scale)
                        
                        Text("💰 +\(reward) coins")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .transition(.opacity)
                            .padding(.top, 10)
                            .animation(.spring(), value: reward)
                    }
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.4), lineWidth: 4)
                        )

                    HStack(spacing: 25) {
                        ForEach(0..<3, id: \.self) { i in
                            SlotMachineReelView(
                                targetSymbol: manager.reelResult[i],
                                stopDelay: baseSpinTime + Double(i) * 1.2,
                                triggerID: manager.spinTriggerID
                            )
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    if manager.isLeverPulled { return }
                    SoundEffect.shared.playSoundEffect(soundEffect: "start-machine")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        manager.startSpin()
                        SoundEffect.shared.playSoundEffect(soundEffect: "spin-machine")
                    }
                }) {
                    Text("PULL LEVER")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.top)
                .disabled(manager.isSpinning)
            }
            .padding()
            .onAppear {
                BackgroundMusicPlayer.shared.play(backsound: "slot-machine")
            }
            .onDisappear {
                BackgroundMusicPlayer.shared.stop()
            }
            .onChange(of: manager.visibleJackpotReward != nil) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    navManager.path = .init([.details(tagId: tagId)])
                }
            }
        }
    }
}


#Preview {
    SlotMachineView(tagId: "ajwbfj")
}
