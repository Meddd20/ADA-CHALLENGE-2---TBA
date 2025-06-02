//
//  CatMeowMimicView.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 01/06/25.
//

import SwiftUI

struct CatMeowMimicView: View {
    @EnvironmentObject var navManager: NavigationManager<Routes>

    @StateObject private var micManager = AudioStreamManager()
    @StateObject private var predictionManager = SoundPredictionManager()

    @State private var isListening = false
    var tagId: String

    init(passedTagId: String) {
        let mic = AudioStreamManager()
        let predictor = SoundPredictionManager()
        predictor.configure(with: mic.audioFormat)
        _micManager = StateObject(wrappedValue: mic)
        _predictionManager = StateObject(wrappedValue: predictor)
        self.tagId = passedTagId
    }

    var body: some View {
        ZStack {
            Image("dumpster")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.4)

                    Image("cat")
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                        .scaleEffect(isListening ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isListening)

                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("🐾 Prove You're One of Us")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 2)

                    Text("Let’s hear that meow — prove you’re one of us.")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .italic()

                    if !isListening {
                        Text("👆 Tap anywhere to begin your meow-formance.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 6)
                            .transition(.opacity)
                    }
                }
                .multilineTextAlignment(.center)
                .padding()

                AudioVisualizer(volume: micManager.currentVolume)

                if isListening {
                    if predictionManager.predictionLabel == "cat" {
                        Text("😼 Welcome to the alley, fellow feline.")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.pink.opacity(0.8))
                            )
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                    removal: .opacity))
                    } else if !predictionManager.isConfirmCat {
                        Text("🙀 Nice try, human.")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.7))
                            )
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                    removal: .opacity))
                    }

                }
                
                Spacer()
            }
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isListening {
                isListening = true
                micManager.start()
                SoundEffect.shared.playSoundEffect(soundEffect: "unfriendly-meow", fileExtension: "wav")
            }
        }
        .onReceive(micManager.audioPublisher.receive(on: DispatchQueue.main)) { buffer, time in
            predictionManager.analyze(buffer: buffer, at: time)
        }
        .onChange(of: predictionManager.isConfirmCat) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                navManager.path = .init([.details(tagId: tagId)])
            }
            SoundEffect.shared.playSoundEffect(soundEffect: "sweet-meow", fileExtension: "wav")
        }
        .onDisappear {
            micManager.stop()
        }
        .animation(.easeOut, value: predictionManager.predictionLabel)
    }
}

#Preview {
    CatMeowMimicView(passedTagId: "hvwufbwi")
}
