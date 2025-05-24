//
//  TestUI.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 24/05/25.
//

import SwiftUI

struct TestUI: View {
    @State private var detectedEmotion = "No emotion yet"

    var body: some View {
        ZStack(alignment: .top) {
            CameraViewRepresentable(emotion: $detectedEmotion)
                .edgesIgnoringSafeArea(.all)
            
            Text("Detected Emotion: \(detectedEmotion)")
                .font(.headline)
                .padding()
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 50)
        }    }
}

#Preview {
    TestUI()
}
