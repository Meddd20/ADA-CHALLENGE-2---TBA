//
//  CompassView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 21/05/25.
//

import SwiftUI

let randomNumber = Double.random(in: 0...360)

struct CompassView: View {
    var tagId: String
    
    @StateObject private var compass = CompassModel()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    @StateObject private var haptic = HapticModel()
    
    @State private var timer: Timer?
    @State var isPresented: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "location.north.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(-compass.heading))
                
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.gray)
                    .frame(width: 200, height: 200)
                
                CompassArc(startAngle: compass.arc - 5, endAngle: compass.arc + 5)
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.blue)
            }
            .onAppear {
                compass.overrideArc(randomNumber)
            }
            
            Text(String(format: "%.0f°", compass.heading))
                .font(.title)
                .padding()
            Text(compass.grace ? "Hold on tight!" : "Keep going!")
                .font(.title2)
                .padding()
                .onChange(of: compass.success, {
                    if compass.success {
                        haptic.playHaptic(duration: 1)
                        isPresented = true
                        timer?.invalidate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            navManager.path = .init([.details(tagId: tagId)])
                        }
                    }
                })
                .onChange(of: compass.grace, {
                    if compass.grace {
                        guard timer == nil else { return }
                        
                        haptic.playHaptic(duration: 0.1)
                        
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            haptic.playHaptic(duration: 0.1)
                        }
                    } else {
                        timer?.invalidate()
                        timer = nil
                    }
                })
                .onDisappear {
                    timer?.invalidate()
                }
                
        }
        .alert(isPresented: $isPresented) {
            Alert(title: Text("Congratulations!"), message: Text("You got it right!"))
        }
        Spacer()
        Text("Tilt the device to see the heading")
    }
}

#Preview {
    CompassView(tagId: "123")
}
