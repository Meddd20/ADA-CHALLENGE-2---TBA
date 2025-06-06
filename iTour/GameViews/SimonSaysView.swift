//
//  SimonSaysView.swift
//  iTour
//
//  Created by Medhiko Biraja on 03/06/25.
//

import SwiftUI

struct SimonSaysScreen: View {
    @State private var label = "None"
    @State private var confidence = 0.0
    @State private var isDone = false
    @State private var simonSays = "Sit"
    @State private var isSimonSays = true
    @State private var correctCount = 0
    @State private var canCheck = true
    @State private var checkTimer: Timer?
    @State private var previousPose = "None"
    @State private var roundStartedAt = Date()
    @State private var countdownValue = 3
    @State private var showCountdown = false
    
    var tagId: String
    var onComplete: (() -> Void)
    
    func gradientColors(for label: String) -> [Color] {
        switch label.lowercased() {
        case "sit", "sitting":
            return [.blue, .cyan]
        case "stand", "stand still":
            return [.orange, .red]
        case "none":
            return [.gray, .gray.opacity(0.6)]
        default:
            return [.indigo, .purple]
        }
    }
    
    func randomizedSimonSays() {
        previousPose = label
        
        let options = ["Sit", "Stand still"]
        simonSays = options.randomElement() ?? "Sit"
        
        isSimonSays = Bool.random()
    }
    
    func normalizedPose(_ raw: String) -> String {
        switch raw.lowercased() {
        case "sit", "sitting":
            return "sit"
        case "stand", "stand still", "standing still":
            return "stand"
        default:
            return raw.lowercased()
        }
    }

    
    var body: some View {
        ZStack {
            VStack(spacing: 0){
                Spacer().frame(height: 24)
                
                if showCountdown {
                    Text("\(countdownValue)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                        .transition(.scale)
                        .animation(.easeInOut, value: countdownValue)
                } else {
                    Text(isSimonSays ? "🧠 Simon Says" : "")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.indigo)
                    
                    ZStack {
                        Text(simonSays.uppercased())
                            .font(.system(size: 54, weight: .heavy, design: .rounded))
                            .foregroundColor(.black.opacity(0.3))
                            .offset(x: 3, y: 3)
                        
                        Text(simonSays.uppercased())
                            .font(.system(size: 54, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(simonSays.uppercased())
                            .font(.system(size: 54, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: gradientColors(for: simonSays),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .animation(.easeInOut, value: simonSays)
                }
                
                Text("Score: \(correctCount)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.indigo.opacity(0.1))
                    .foregroundColor(.indigo)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.indigo, lineWidth: 1))
                    .padding([.top, .bottom], 8)
                    .padding(.trailing, 12)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                
                SimonSaysCameraView(resultLabel: $label, confidence: $confidence, isDone: $isDone)
                    .frame(height: 450)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Text("You are currently")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                ZStack {
                    Text(label.uppercased())
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.black.opacity(0.3))
                        .offset(x: 3, y: 3)
                    
                    Text(label.uppercased())
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(label.uppercased())
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors(for: label),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .animation(.easeInOut, value: label)
                
                Spacer()
            }
        }
        .padding()
        .onChange(of: label) {
            guard canCheck else { return }
            
            let userPose = normalizedPose(label.lowercased())
            let expectedPose = normalizedPose(simonSays.lowercased())
            var isCorrect = false
            
            if isSimonSays {
                isCorrect = userPose == expectedPose
            } else {
                isCorrect = userPose == normalizedPose(previousPose)
            }
            
            if isCorrect {
                correctCount += 1
                if correctCount == 5 {
                    onComplete()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    previousPose = label
                    startNewRound()
                }
            }
            canCheck = false
        }

    }
    
    func startNewRound() {
        canCheck = false
        showCountdown = true
        countdownValue = 3

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownValue > 1 {
                countdownValue -= 1
            } else {
                timer.invalidate()
                showCountdown = false

                previousPose = label
                randomizedSimonSays()
                canCheck = true

                // Optional: Add buffer before auto-checking
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    let userPose = normalizedPose(label)
                    let expectedPose = normalizedPose(simonSays)
                    var isCorrect = false

                    if isSimonSays {
                        isCorrect = userPose == expectedPose
                    } else {
                        isCorrect = userPose == normalizedPose(previousPose)
                    }

                    if isCorrect {
                        correctCount += 1
                        if correctCount == 5 {
                            onComplete()
                            return
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        startNewRound()
                    }
                }
            }
        }
    }
}

#Preview {
    SimonSaysScreen(tagId: "wufbuwbf", onComplete: {})
}
