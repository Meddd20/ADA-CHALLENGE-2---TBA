//
//  BallBalancingGameView.swift
//  Ball Balancing Game
//
//  Created by Wira Wibisana on 21/05/25.
//
import SwiftUI
import SpriteKit

struct BallBalancingGameView: View {
    @State private var gameState: GameState = .playing
    @EnvironmentObject var navManager: NavigationManager<Routes>

    var tagId: String
    
    enum GameState {
        case playing, won, lost
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpriteView(
                    scene: {
                        let scene = BallBalancingGameScene(size: geometry.size)
                        scene.scaleMode = .resizeFill
                        scene.onGameOver = { didWin in
                            gameState = didWin ? .won : .lost
                            
                            if didWin {
                                navManager.path = .init([.details(tagId: tagId)])
                            }
                        }
                        return scene
                    }()
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    if gameState == .playing {
                        Text("Tilt to guide the ghost to the goal!")
                            .font(.headline)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}
struct BallBalancingGameView_Previews: PreviewProvider {
        static var previews: some View {
            BallBalancingGameView(tagId: "agweudf")
        }
    }
