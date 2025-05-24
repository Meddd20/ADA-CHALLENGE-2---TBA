//
//  CameraExpression.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 24/05/25.
//

import SwiftUI
import Mentalist



let possibleEmotions: [Emotion] = [.happy, .sad, .angry, .fear]
struct CameraExpression: View {
    var tagId: String
    var randomEmotion = possibleEmotions.randomElement() ?? .neutral
    
    @State private var isPresented: Bool = false
    @State private var isDone: Bool = false
    @State private var detectedEmotion: Emotion = .neutral

    @StateObject var haptic = HapticModel()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    
    var body: some View {
        Text("Make a \(randomEmotion.rawValue) face!")
            .font(.title)
            .fontWeight(.semibold)
        CameraViewRepresentable(emotion: $detectedEmotion, isDone: $isDone)
            .edgesIgnoringSafeArea(.all)
            .onChange(of: detectedEmotion, {
                if detectedEmotion == randomEmotion {
                    isDone = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        haptic.playHaptic()
                        isPresented = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        navManager.path = .init([.details(tagId: tagId)])
                    }
                }
            })
            .padding(.horizontal)
            .alert(isPresented: $isPresented) {
                Alert(title: Text("Congratulations!"), message: Text("You got it right!"))
            }
        
        Text("Detected Emotion: \(detectedEmotion)")
            .font(.headline)
            .padding()
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 50)
    }
}

#Preview {
    CameraExpression(tagId: "123")
}
