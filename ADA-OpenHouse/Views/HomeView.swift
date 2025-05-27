//
//  HomeView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navManager: NavigationManager<Routes>
    @StateObject private var shakeMotionManager = ShakeMotionManager()
    @StateObject private var nfcReader = NFCReader()
    @State private var isWaitOver = true
    @State private var progress = 0.3
    @State private var isDetectingShake = false
    @State private var manuallyShowSheet: Bool = false
    
    @StateObject private var haptic = HapticModel()
    
    var showSheetBinding: Binding<Bool> {
        Binding(get: {
            isWaitOver && (shakeMotionManager.didShakeDetected && isDetectingShake || manuallyShowSheet)
        }, set: { newValue in
            if !newValue {
                shakeMotionManager.didShakeDetected = false
                isWaitOver = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    isWaitOver = true
                    manuallyShowSheet = false
                }
            }
        })
    }
    
    var body: some View {
        ZStack {
            Image("bg")
                .resizable()
                .scaledToFill()
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            manuallyShowSheet = true
                        }) {
                            Circle()
                                .overlay {
                                    Image(systemName: "lightbulb.min")
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 40, height: 40)
                                .foregroundStyle(
                                    isWaitOver ? .blue : .gray
                                )
                        }
                        .disabled(!isWaitOver)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 40)
                    Spacer()
                }
            VStack(spacing: 20) {
                Text("Have fun and find them!")
                    .font(.system(size: 35, weight: .heavy))
                    .fontWidth(.expanded)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Image(systemName: "figure.walk.motion")
                    .font(.system(size: 75))
                    .foregroundStyle(.blue)
                    .padding(.vertical)
                
                Text("You've discovered 4/10 hidden spots in ADA!")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.black)
                    .fontWidth(.expanded)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryBlue))
                    .padding(EdgeInsets(top: 15, leading: 40, bottom: 25, trailing: 40))
                
                Button(action: {
                    nfcReader.beginScanning()
                }) {
                    
                    Text("Scan Tag")
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 264, height: 51)
                        .background(Color.primaryBlue)
                        .foregroundStyle(.white)
                        .cornerRadius(20)
                }
                .padding(.top)
            }
            .padding()
            .onChange(of: shakeMotionManager.didShakeDetected, {
                if(shakeMotionManager.didShakeDetected && isDetectingShake && isWaitOver) {
                    haptic.playHaptic(duration: 0.7)
                }
            })
            .onAppear {
                shakeMotionManager.didShakeDetected = false
                isDetectingShake = true
                shakeMotionManager.detectShakeMotion()
                
                nfcReader.assignOnScan {
                    if(nfcReader.scannedMessage.isEmpty) {
                        return;
                    }
                    
                    let cleaned = nfcReader.scannedMessage.trimmingCharacters(in: .controlCharacters.union(.whitespacesAndNewlines))
                    
                    let tagId = extractTagId(URL(string: cleaned))
                    if let tagId = tagId {
                        navManager.path.append(.instruction(tagId: tagId))
                    }
                }
            }
            .onDisappear {
                isDetectingShake = false
                shakeMotionManager.resetShakeDetection()
                shakeMotionManager.stopShakeDetection()
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
}

#Preview {
    HomeView()
}
