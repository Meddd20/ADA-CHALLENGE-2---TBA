//
//  AudioVisualizerView.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 01/06/25.
//

import SwiftUI

struct AudioVisualizer: View {
    let volume: CGFloat
    let barCount: Int = 20
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<barCount, id: \.self) { i in
                Capsule()
                    .fill(Color.pink)
                    .frame(width: 4, height: randomHeight(for: volume))
                    .shadow(color: .pink.opacity(0.6), radius: 4)
                    .animation(.easeOut(duration: 0.2), value: volume)
            }
        }
        .frame(height: 100)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
    
    private func randomHeight(for volume: CGFloat) -> CGFloat {
        let base = volume * 100
        return CGFloat.random(in: max(2, base * 0.2)...max(10, base * 1.0))
    }
}
