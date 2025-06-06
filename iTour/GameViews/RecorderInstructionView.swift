//
//  RecorderInstructionView.swift
//  iTour
//
//  Created by Ramdan on 16/05/25.
//

import SwiftUI

struct RecorderInstructionView: View {
    @StateObject var recorder = AudioRecorder()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    @State private var showAlert = false
    @StateObject var haptic = HapticModel()
    
    var tagId: String
    var onComplete: (() -> Void)

    var body: some View {
        // Instruction Card
        VStack {
            VStack {
                Text("Read this carefully")
                    .font(.title2)
                VStack {
                    Image(systemName: "waveform")
                        .font(.system(size: 100))
                        .foregroundStyle(.blue)
                        .padding(.vertical, 30)
                    Text(String(format: "%.0f%%", loudnessHeight(from: recorder.currentLoudness, treshold: recorder.loudnessThreshold)))
                        .foregroundColor(recorder.isTooLoud ? .red : .primary)
                    ProgressView(value: loudnessHeight(from: recorder.currentLoudness, treshold: recorder.loudnessThreshold), total: 100)
                    Text("Scream as loud as you can!")
                        .font(.title3)
                        .multilineTextAlignment(.center )
                }
                .onDisappear { recorder.stopRecording() }
                .onChange(of: recorder.isTooLoud, {
                    if recorder.isTooLoud {
                        onComplete()
                    }
                })
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 40)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.secondary, lineWidth: 0.5)
                    .shadow(color: .primary, radius: 2)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 40)
        
        Spacer()
        
        VStack {
            Button(action: {
                if(recorder.isRecording) {
                    recorder.stopRecording()
                } else {
                    recorder.startRecording()
                }
            }) {
                Text(recorder.isRecording ? "Stop" : "Start Now")
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.vertical, 30)
            .background(
                recorder.isRecording ? Color.red : Color.blue
            )
            .foregroundColor(.white)
            .cornerRadius(30)
        }
        .padding(.horizontal, 40)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Oops!"), message: Text("You scream too loud!"))
        }
    }
       
}
