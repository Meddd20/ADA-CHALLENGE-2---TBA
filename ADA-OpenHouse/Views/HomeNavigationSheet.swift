//
//  HomeNavigationSheet.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 19/05/25.
//

import SwiftUI

struct BottomSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var shakeMotionManager: ShakeMotionManger
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    
    let duration: TimeInterval = 10.0
    
    var body: some View {
        VStack (alignment: .center, spacing: 20){
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(Color.darkBlue)
                .padding(.top, 10)
            
            Text("Riddle")
                .font(.system(size: 27, weight: .heavy))
            
            Text("I turn beans into liquid gold. Hot and strong, I never get old.")
                .font(.system(size: 17, weight: .medium))
                .multilineTextAlignment(.center)
            
            Text("What am I?")
                .font(.system(size: 17, weight: .medium))
                .padding(.vertical, 10)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.darkBlue))
                .padding(.horizontal, 40)
            
        }
        .padding()
        .onAppear { startTimer() }
        .onDisappear {
            timer?.invalidate()
            shakeMotionManager.didShakeDetected = false
        }
    }
    
    func startTimer() {
        progress = 0
        timer?.invalidate()
        
        let interval = 0.1
        var elapsed: TimeInterval = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            elapsed += interval
            progress = min(elapsed / duration, 1.0)
            
            if elapsed >= duration {
                timer.invalidate()
                dismiss()
            }
        }
    }
}
