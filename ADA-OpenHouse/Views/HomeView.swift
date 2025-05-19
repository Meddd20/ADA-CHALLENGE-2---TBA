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
                CarouselView(imageNames: ["jensen_huang", "knight", "jensen_huang", "knight", "jensen_huang", "knight"])
            }
            .frame(maxHeight: .infinity)
            
            VStack {
                Button(action: {
                    nfcReader.beginScanning()
                }) {
                    Circle()
                        .foregroundColor(.blue)
                        .overlay {
                            VStack {
                                Image(systemName: "wifi")
                                    .foregroundColor(.white)
                                    .font(.system(size: 100))
                                Text("Scan Tag")
                                    .foregroundStyle(.white)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(width: 200)
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
