//
//  RockPaperScissorView.swift
//  iTour
//
//  Created by Ramdan on 27/05/25.
//

import SwiftUI

struct RockPaperScissorsView: View {
    var tagId: String
    var onComplete: (() -> Void)

    @State var randomGesture = ["rock", "paper", "scissors"].randomElement() ?? "rock"
    
    @State private var isPresented: Bool = false
    @State private var isDone: Bool = false
    @State private var gesture: RPSResult?
    @State private var message = "You WIN"
    @StateObject var haptic = HapticModel()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    
    var body: some View {
        RPSCameraViewRepresentable(gesture: $gesture, isDone: $isDone)
            .edgesIgnoringSafeArea(.all)
            .padding(.horizontal)
            .alert(isPresented: $isPresented) {
                Alert(title: Text("Congratulations!"), message: Text(message))
            }
            .onChange(of: (gesture?.identifier ?? "None") + (gesture?.confidence?.description ?? "None"), {
                if gesture?.identifier == randomGesture {
                    if gesture?.confidence ?? 0.0 > 0.9 {
                        isDone = true
                        onComplete()
                    }
                } else {
                    haptic.playHaptic()
                    isPresented = true
                    message = "You LOSE! Try again!"
                    isDone = true
                    randomGesture = ["rock", "paper", "scissors"].randomElement() ?? "rock"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isDone = false
                        isPresented = false
                        message = "You WIN"
                    }
                }
            })
        
        
        Text("Detected gesture: \(gesture?.identifier ?? "None")(\(String(format: "%.2f", gesture?.confidence ?? 0.0)))")
            .font(.headline)
            .padding()
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 50)
    }
}

