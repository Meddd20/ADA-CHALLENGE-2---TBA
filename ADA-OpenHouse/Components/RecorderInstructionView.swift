//
//  RecorderInstructionView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 16/05/25.
//

import SwiftUI

struct RecorderInstructionView: View {
    @ObservedObject var recorder = AudioRecorder()
    
    private func loudnessHeight(from dB: Float, treshold: Float) -> CGFloat {
        // Normalize: -160 to 0 dB mapped to 0–200 pts
        let normalized = max(0, min(1, (dB + (40 + treshold)) / (40 + treshold)))
        return CGFloat(normalized) * 100
    }
    
    var body: some View {
        VStack {
            Text("Scream as loud as you can!")
                .font(.headline)
                .padding(.top)
            VStack {
                
                Text(String(format: "%.2f%%", loudnessHeight(from: recorder.currentLoudness, treshold: recorder.loudnessThreshold)))
                    .foregroundColor(recorder.isTooLoud ? .red : .primary)
                
                ProgressView(value: loudnessHeight(from: recorder.currentLoudness, treshold: recorder.loudnessThreshold), total: 100)
                
                if recorder.isTooLoud {
                    Text("⚠️ Loud Sound Detected!")
                        .foregroundColor(.red)
                        .bold()
                }
                
                HStack {
                    Button(action: {
                        if(recorder.isRecording) {
                            recorder.stopRecording()
                        } else {
                            recorder.startRecording()
                        }
                    }) {
                        Text(recorder.isRecording ? "Stop" : "Start")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 5)
                    .background(
                        recorder.isRecording ? Color.red : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .onDisappear {
                recorder.stopRecording()
            }
        }    }
}

#Preview {
    RecorderInstructionView()
}
