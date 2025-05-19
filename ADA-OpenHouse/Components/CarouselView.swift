//
//  CarouselView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 19/05/25.
//

import SwiftUI

struct CarouselView: View {
    let imageNames: [String]

    @State private var scrollOffset: CGFloat = 0
    @State private var currentIndex: Int = 0
    @State private var images: [String] = []
    @State private var timer: Timer? = nil
    @State private var autoScrollEnabled: Bool = true
    @State private var id = UUID()

    @State private var imageWidth: CGFloat = 0 // Calculate dynamically
    let autoScrollInterval: TimeInterval = 3.0

    var body: some View {
        VStack {
            VStack {
                Image(imageNames[currentIndex])
                    .resizable()
                    .scaledToFit()
            }
            .transition(.slide.combined(with: .blurReplace).combined(with: .opacity).combined(with: .scale(0)))
            .id(id)
        }
        .onAppear { startAutoScroll() }
        .onDisappear { stopAutoScroll() }

    }

    func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentIndex = (currentIndex + 1) % imageNames.count
                    scrollOffset = CGFloat(currentIndex) * imageWidth
                    id = UUID()
                }
            }
        }
    }

    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    CarouselView(imageNames: ["jensen_huang", "jensen_huang", "jensen_huang", "jensen_huang", "jensen_huang"])
}
