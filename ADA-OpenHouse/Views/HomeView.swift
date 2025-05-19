//
//  HomeView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var shakeMotionManager = ShakeMotionManger()
    @State private var isWaitOver = true
    
    var showSheetBinding: Binding<Bool> {
        Binding(get: {
            isWaitOver && shakeMotionManager.didShakeDetected
        }, set: { newValue in
            if !newValue {
                shakeMotionManager.didShakeDetected = false
                isWaitOver = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    isWaitOver = true
                }
            }
        })
    }
        
    var body: some View {
        VStack() {
            Spacer()
                .frame(height: 60)
            
            Text("iTour")
                .font(.system(size: 35, weight: .bold))
            
            Spacer()
                .frame(height: 470)
            
            Button("Scan NFC") {
                
            }
            .padding()
            .frame(width: 250, height: 60)
            .background(Color.primaryBlue)
            .foregroundStyle(.white)
            .cornerRadius(10)
            
            Text(isWaitOver ? "LALALA" : "BEBEBE")
            
            Spacer()
            
        }
        .padding()
        .onAppear {
            shakeMotionManager.detectShakeMotion()
        }
        .onDisappear {
            shakeMotionManager.resetShakeDetection()
        }
        .sheet(
            isPresented: showSheetBinding,
            onDismiss: {
            isWaitOver = false
            shakeMotionManager.didShakeDetected = false
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                isWaitOver = true
                shakeMotionManager.detectShakeMotion()
            }
        }) {
            BottomSheetView(shakeMotionManager: shakeMotionManager)
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.45)])
        }
    }
}
