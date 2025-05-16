//
//  HomeView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//
//aaaa
import SwiftUI

struct HomeView: View {
    @StateObject private var nfcReader = NFCReader()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    
    var body: some View {
        VStack(spacing: 20) {
            Text("NFC Reader")
                .font(.largeTitle)
                .bold()
            Button("Start NFC Scan") {
                nfcReader.beginScanning()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onChange(of: nfcReader.scannedMessage, {
            if(nfcReader.scannedMessage.isEmpty) {
                return;
            }
            
            navManager.path.append(.instruction(tagId: nfcReader.scannedMessage))
        })
        
    }
}

#Preview {
    HomeView()
}
