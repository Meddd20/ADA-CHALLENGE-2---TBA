//
//  SpeechView.swift
//  iTour
//
//  Created by Ramdan on 28/05/25.
//

import SwiftUI

struct SpeechView: View {
    var tagId: String
    var onComplete: (() -> Void)

    var sentenceGenerator = SentenceGenerator()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var tts = TextToSpeechModel()
    @StateObject private var haptic = HapticModel()

    @EnvironmentObject var navManager: NavigationManager<Routes>
    
    @State private var targetText = ""
    @State private var isShowText = false
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HStack {
                    Button(action: {
                        tts.speak(targetText)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .padding()
                            .background(.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(targetText.isEmpty)
                    
                    Button(action: {
                        let randomText = sentenceGenerator.generate()
                        targetText = randomText
                        isShowText = false
                        tts.speak(randomText)
                    }) {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                            .font(.headline)
                            .padding(10)
                            .background(.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                VStack {
                    if isShowText {
                        Text(targetText)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    } else {
                        Button(action: {
                            isShowText = true
                        }) {
                            Text("Show Text")
                        }
                    }
                }
                .padding()
            }
            
            ScrollView {
                Text(speechRecognizer.transcribedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 300)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
                Button(action: {
                    if speechRecognizer.isRecording {
                        speechRecognizer.stopTranscribing()
                    } else {
                        speechRecognizer.startTranscribing()
                    }
                }) {
                    Text(speechRecognizer.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.title2)
                        .padding()
                        .background(speechRecognizer.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            
        }
        .padding()
        .onAppear {
            speechRecognizer.requestAuthorization()
            let randomText = sentenceGenerator.generate()
            targetText = randomText
            
            tts.speak(randomText)
        }
        .onChange(of: speechRecognizer.transcribedText, {
            if areSentencesSimilar(targetText, speechRecognizer.transcribedText) {
                speechRecognizer.stopTranscribing()
                onComplete()
            }
        })
        .alert(isPresented: $isPresented) {
            Alert(title: Text("Congratulations!"), message: Text("You got it right!"))
        }
    }
}
