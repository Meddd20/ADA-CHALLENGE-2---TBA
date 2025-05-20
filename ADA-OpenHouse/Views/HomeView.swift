//
//  HomeView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var nfcReader = NFCReader()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    
    var body: some View {
        VStack(spacing: 20) {
            Text("iTour")
                .font(.system(size: 50))
                .fontWeight(.heavy)
                .bold()
                .padding(.top)
            Text("Shake to discover something hidden")
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            VStack {
                CarouselView(imageNames: ["home-1", "home-2"])
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            
            VStack {
                Button(action: {
                    nfcReader.beginScanning()
                }) {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundColor(.blue)
                        .overlay {
                            VStack {
                                Image("nfc-scan")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 86.71)
                                Text("Scan Tag")
                                    .foregroundStyle(.white)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 192)
                        .padding(.horizontal)
                        .shadow(color: Color.darkBlue, radius: 0, x: 0, y: 5)
                }
                .padding(.bottom)
                
            }
        }
        .padding()
        .onAppear() {
            nfcReader.assignOnScan {
                if(nfcReader.scannedMessage.isEmpty) {
                    return;
                }
                
                navManager.path.append(.instruction(tagId: nfcReader.scannedMessage))
            }
        }
    }
}


#Preview {
    HomeView()
}
