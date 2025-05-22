//
//  PunchDetection.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 21/05/25.
//

import SwiftUI

struct PunchDetection: View {
    @StateObject var punchManager = PunchMotionManager()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    @State private var isDetectingPunch = false
    
    var tagId: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 60)

            VStack (spacing: 8) {
                Text("👊 Punch Detector")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                
                Text("Punch as fast as you can while holding your phone — show us your reflex power!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            
            VStack(spacing: 12) {
                Text("Peak Acceleration")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(String(format: "%.2f G", punchManager.peakAcceleration))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                    .animation(.easeInOut, value: punchManager.peakAcceleration)
            }

            Group {
                if punchManager.didPunchDetected {
                    Text("✅ Punch Detected!")
                        .font(.title2)
                        .foregroundColor(.green)
                        .transition(.scale)
                } else {
                    Text("👀 Waiting for punch...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 40)
            .animation(.easeInOut, value: punchManager.didPunchDetected)

            Image(systemName: "waveform.path.ecg")
                .resizable()
                .frame(width: 60, height: 30)
                .foregroundColor(.blue.opacity(0.7))
                .padding(.top, 20)
                .opacity(0.5)
                .scaleEffect(punchManager.didPunchDetected ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: punchManager.didPunchDetected)

            Spacer()
            
            Text("Start punching to begin")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .onAppear {
            punchManager.resetPeakPunch()
            punchManager.detectPunchingMotion()
            isDetectingPunch = true
        }
        .onDisappear {
            punchManager.stopDetectMotion()
            isDetectingPunch = false
        }
        .onChange(of: punchManager.didPunchDetected) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    navManager.path.append(.details(tagId: tagId))
                }
            }
        }

    }
}

#Preview {
    PunchDetection(tagId: "alla")
}
