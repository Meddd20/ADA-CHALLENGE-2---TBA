//
//  InstructionStartView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 28/05/25.
//

import SwiftUI


struct Instruction {
    var type: GameViewType
    var icon: String
    var text: String
}

let instructions: [Instruction] = [
    .init(type: .rockPaperScissors, icon: "scissors", text: "Hands up! Play Rock, Paper, Scissors using real gestures!"),
    .init(type: .punch, icon: "figure.boxing", text: "Punch as fast as you can while holding your phone!"),
    .init(type: .recorder, icon: "person.wave.2.fill", text: "Let it all out! Scream until you hit the mark!"),
    .init(type: .flip, icon: "repeat", text: "Get ready… wait for it… flip at the right moment!"),
    .init(type: .compass, icon: "location.north.circle", text: "Find the way! Rotate your phone to the right direction!"),
    .init(type: .ballBalancing, icon: "flag.pattern.checkered", text: "Tilt and guide! Help the ghost reach the flag!"),
    .init(type: .cameraExpression, icon: "face.smiling", text: "Make the face! Match the expression to win!"),
    .init(type: .slotMachine, icon: "7.square", text: "Feeling lucky? Spin the slot and hit the jackpot!"),
    .init(type: .wordle, icon: "text.word.spacing", text: "Guess the word in 6 tries. Every letter counts!"),
    .init(type: .cubeShaper, icon: "cube", text: "Shape it right! Match the model as closely as you can!"),
    .init(type: .speechRecognition, icon: "person.line.dotted.person.fill", text: "Listen carefully. Can you repeat it perfectly?"),
    .init(type: .anomaly, icon: "flowchart", text: "Spot the odd one out! Scan the data and tap the anomaly!")
]


struct InstructionStartView: View {
    @Binding var game: GameViewType
    @State private var instruction = instructions[0]
    @Binding var isPlayingGame: Bool
    @State private var isRandomizing = false
    @State private var randomizeTimer: Timer?
    @State private var currentRandomIndex = 0
    
    var body: some View {
        ZStack {
            Image("bg")
                .resizable()
                .scaledToFill()
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        SoundEffect.shared.playSoundEffect(soundEffect: "instruction-randomizer")
                        startRandomizing()
                    }) {
                        Circle()
                            .fill(isRandomizing ? Color.gray : .blue)
                            .overlay {
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .foregroundStyle(.white)
                                    .rotationEffect(.degrees(isRandomizing ? 360 : 0))
                            }
                            .frame(width: 40, height: 40)
                    }
                    .disabled(isRandomizing)
                }
                .padding(.top, 50)
                .padding(.trailing, 50)
                Spacer()
            }
            VStack {
                Text("Finish the quest to unveil!")
                    .font(.callout)
                    .fontWidth(.expanded)
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
                VStack {
                    Image(systemName: instruction.icon)
                        .font(.system(size: 40))
                        .padding(.vertical, 30)
                        .contentTransition(.symbolEffect(.replace))
                    Text(instruction.text)
                        .font(.title2)
                        .fontWeight(.heavy)
                        .fontWidth(.expanded)
                        .multilineTextAlignment(.center)
                        .contentTransition(.opacity)
                }
                .transition(.opacity)
                .id(game)
                Button(action: {
                    isPlayingGame = true
                }) {
                    Text("Start Now")
                        .font(.system(size: 20, weight: .bold))
                        .frame(height: 51)
                        .frame(maxWidth: .infinity)
                        .background(isRandomizing ? Color.gray : Color.primaryBlue)
                        .foregroundStyle(.white)
                        .cornerRadius(20)
                        .fontWidth(.expanded)
                }
                .disabled(isRandomizing)
                .padding(.top)
            }
            .background(.white)
            .padding(.horizontal, 50)
            .padding(.vertical, 50)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.2), radius: 3)
                    .frame(width: 300)
            }
            .frame(width: 300)
            .onAppear {
                instruction = instructions.first(where: { $0.type == game }) ?? instructions[0]
            }
        }
    }

    // Randomizing logic
    private func startRandomizing() {
        isRandomizing = true
        randomizeTimer?.invalidate()
        currentRandomIndex = 0
        
        randomizeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            currentRandomIndex = Int.random(in: 0..<instructions.count)
            instruction = instructions[currentRandomIndex]
        }

        // Stop randomizing after 1.2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            randomizeTimer?.invalidate()
            randomizeTimer = nil
            isRandomizing = false
        }
    }
}

// MARK: - Preview
#Preview {
    InstructionStartView(
        game: .constant(.cameraExpression),
        isPlayingGame: .constant(false)
    )
}
