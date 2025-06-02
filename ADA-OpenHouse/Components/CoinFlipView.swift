////
////  CoinFlipView.swift
////  ADA-OpenHouse
////
////  Created by Levana on 28/05/25.
////
//
import SwiftUI

struct CoinFlipView: View {
    @StateObject private var model = CoinFlipModel()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    
    var tagId: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated Background
                AnimatedBackgroundView()
                
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                        .frame(height: geometry.size.height * 0.25)
                    
                    // Coin Display Section
                    coinDisplaySection
                        .frame(height: geometry.size.height * 0.4)
                    
                    // Controls Section
                    controlsSection
                        .frame(height: geometry.size.height * 0.35)
                }
            }
            .onChange(of: model.coinResult) {
                if model.coinResult == model.userGuess {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        navManager.path = .init([.details(tagId: tagId)])
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("COIN FLIP")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(2)
                
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            if model.gameState == .waiting && !model.hasPlayed {
                Text("Choose wisely and test your luck!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .fontWeight(.medium)
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Coin Display Section
    @ViewBuilder
    private var coinDisplaySection: some View {
        ZStack {
            // Glow Effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 20)
            
            // Main Coin
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 0.8, green: 0.6, blue: 0.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                
                coinContentView
            }
            .rotation3DEffect(
                .degrees(model.gameState == .flipping ? 1440 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .scaleEffect(model.gameState == .flipping ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 1.5), value: model.gameState)
        }
    }
    
    @ViewBuilder
    private var coinContentView: some View {
        Group {
            if model.gameState == .flipping {
                Image(systemName: "rays")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(model.gameState == .flipping ? 360 : 0))
                    .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: model.gameState)
            } else if let coinResult = model.coinResult, model.gameState == .result {
                Image(systemName: coinResult.imageName)
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: coinResult)
            } else {
                Image(systemName: "circle.dashed")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    // MARK: - Controls Section
    @ViewBuilder
    private var controlsSection: some View {
        VStack(spacing: 30) {
            if model.gameState == .waiting {
                choiceButtonsView
            } else if model.gameState == .flipping {
                flippingStateView
            } else if model.gameState == .result {
                resultDisplayView
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var choiceButtonsView: some View {
        VStack(spacing: 20) {
            Text("Make Your Choice")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 25) {
                // Picture Button
                Button(action: {
                    model.makeGuess(.heads)
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.pink, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: .pink.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                            VStack(spacing: 8) {
                                Image(systemName: CoinSide.heads.imageName)
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("PICTURE")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(0.95)
                .animation(.easeInOut(duration: 0.1), value: model.gameState)
                
                // Number Button
                Button(action: {
                    model.makeGuess(.tails)
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: .cyan.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                            VStack(spacing: 8) {
                                Image(systemName: CoinSide.tails.imageName)
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("NUMBER")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(0.95)
                .animation(.easeInOut(duration: 0.1), value: model.gameState)
            }
        }
    }
    
    @ViewBuilder
    private var flippingStateView: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .scaleEffect(model.gameState == .flipping ? 1.5 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: model.gameState
                        )
                }
            }
            
            Text("FLIPPING...")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .tracking(3)
        }
    }
    
    @ViewBuilder
    private var resultDisplayView: some View {
        VStack(spacing: 25) {
            // Result Message
            VStack(spacing: 15) {
                Text(model.isWinner ? "VICTORY!" : "DEFEAT!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(model.isWinner ? .green : .red)
                    .shadow(color: model.isWinner ? .green.opacity(0.3) : .red.opacity(0.3), radius: 10)
                
                if let userGuess = model.userGuess,
                   let coinResult = model.coinResult {
                    VStack(spacing: 8) {
                        Text("You chose: \(userGuess.rawValue)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Result: \(coinResult.rawValue)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            
            if !model.isWinner {
                // Action Button
                Button(action: {
                    model.resetGame()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: model.isWinner ? "arrow.clockwise" : "arrow.counterclockwise")
                            .font(.title3)
                        
                        Text(model.isWinner ? "PLAY AGAIN" : "TRY AGAIN")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: model.isWinner ? [.green, .mint] : [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                }
                .scaleEffect(0.95)
                .animation(.easeInOut(duration: 0.1), value: model.isWinner)
            }
        }
    }
}

// MARK: - Animated Background
struct AnimatedBackgroundView: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: animateGradient ?
                [Color.purple, Color.blue, Color.indigo, Color.purple] :
                [Color.indigo, Color.purple, Color.blue, Color.indigo],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

#Preview {
    CoinFlipView(tagId: "vfuwjk")
}
