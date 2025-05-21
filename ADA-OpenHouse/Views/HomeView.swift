//
//  HomeView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navManager: NavigationManager<Routes>
    @StateObject private var shakeMotionManager = ShakeMotionManger()
    @StateObject private var nfcReader = NFCReader()
    @State private var isWaitOver = true
    @State private var progress = 0.3
    
    @StateObject private var haptic = HapticModel()
    
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
        VStack(spacing: 20) {    
            Text("iTour")
                .font(.system(size: 35, weight: .heavy))
                .fontWidth(.expanded)
                .bold()

            Text("Shake to discover something hidden")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.1))
                .fontWidth(.expanded)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            CarouselView(imageNames: ["nfc-image1", "nfc-image2", "nfc-image3", "nfc-image4", "nfc-image5"])
                .frame(width: 352, height: 320)
            
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
                HStack (spacing: 20){
                    Image("nfc-scan-icon")
                        .frame(maxWidth: 43)
                    Text("Scan Tag")
                        .font(.system(size: 24, weight: .medium))
                }
                .frame(width: 264, height: 81)
                .background(Color.primaryBlue)
                .foregroundStyle(.white)
                .cornerRadius(20)
            }
            .onChange(of: shakeMotionManager.didShakeDetected, {
                if(shakeMotionManager.didShakeDetected) {
                    haptic.playHaptic(duration: 1)
                }
            })
            
        }
        .padding()
        .onAppear {
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

#Preview {
    HomeView()
}
