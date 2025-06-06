//
//  MimicCatSoundView.swift
//  iTour
//
//  Created by Medhiko Biraja on 28/05/25.
//

import SwiftUI

struct MimicCatSoundView: View {
    @State private var isRecording = false
    @State private var resultText: String = "Try mimicking a cat 🐱"
    @State private var confidence: Double = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🐾 Mimic the Cat")
                .font(.largeTitle)
                .bold()
            
            Text("Make a meow, purr, or hiss!")
                .font(.title2)
                .foregroundColor(.gray)

            Circle()
                .fill(isRecording ? Color.pink : Color.gray.opacity(0.3))
                .frame(width: 150, height: 150)
                .overlay(
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                )
                .animation(.easeInOut, value: isRecording)
            
            Button(action: {
                isRecording.toggle()
                if isRecording {
                    startRecording()
                } else {
                    stopRecordingAndPredict()
                }
            }) {
                Text(isRecording ? "Stop Mimic" : "Start Mimic")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.headline)
            }

            VStack {
                Text(resultText)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                
                if confidence > 0 {
                    ProgressView(value: confidence)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .padding(.horizontal)
                }
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
    
    func startRecording() {
        resultText = "Listening... 🎤"
        confidence = 0.0
    }
    
    func stopRecordingAndPredict() {
        let isCat = Bool.random()
        confidence = Double.random(in: 0.6...1.0)
        resultText = isCat ? "You sound like a cat! 🐱" : "Hmm... more like a dog 🐶"
    }
    
    
}

#Preview {
    MimicCatSoundView()
}

