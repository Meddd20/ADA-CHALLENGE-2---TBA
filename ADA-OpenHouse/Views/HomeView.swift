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
            Text("NFC Reader")
                .font(.largeTitle)
                .bold()
            
            //            Text(nfcReader.scannedMessage.isEmpty ? "Scan an NFC tag" : "Scanned: \(nfcReader.scannedMessage)")
            //                .padding()
            
            //            Button("Start NFC Scan") {
            //                nfcReader.beginScanning()
            //            }
            //            .padding()
            //            .background(Color.blue)
            //            .foregroundColor(.white)
            //            .cornerRadius(10)
            VStack {
                Button("Simulate NFC Tap") {
                    navManager.path.append(.details(tagId: "12345"))
                }
                Button("Simulate admin NFC Tap") {
                    navManager.path.append(.dashboard)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
