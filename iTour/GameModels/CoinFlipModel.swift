//
//  CoinFlipModel.swift
//  iTour
//
//  Created by Levana on 01/06/25.
//
import Foundation
// MARK: - Coin Side Enum
enum CoinSide: String, CaseIterable {
    case heads = "Heads"
    case tails = "Tails"
    
    var imageName: String {
        switch self {
        case .heads:
            return "person.crop.circle" // SF Symbol for heads (picture)
        case .tails:
            return "textformat.123" // SF Symbol for tails (number)
        }
    }
}

// MARK: - Game State Enum
enum GameState {
    case waiting    // Waiting for user guess
    case flipping   // Coin is flipping
    case result     // Showing result
}

// MARK: - Coin Flip Model
@MainActor
class CoinFlipModel: ObservableObject {
    @Published var gameState: GameState = .waiting
    @Published var userGuess: CoinSide?
    @Published var coinResult: CoinSide?
    @Published var isWinner: Bool = false
    @Published var hasPlayed: Bool = false
    
    // MARK: - Public Methods
    func makeGuess(_ guess: CoinSide) {
        guard gameState == .waiting else { return }
        
        userGuess = guess
        flipCoin()
    }
    
    func resetGame() {
        gameState = .waiting
        userGuess = nil
        coinResult = nil
        isWinner = false
        hasPlayed = false
    }
    
    // MARK: - Private Methods
    private func flipCoin() {
        gameState = .flipping
        
        // Simulate coin flip delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.coinResult = self.generateRandomCoinSide()
            self.checkResult()
            self.gameState = .result
            self.hasPlayed = true
        }
    }
    
    private func generateRandomCoinSide() -> CoinSide {
        return CoinSide.allCases.randomElement() ?? .heads
    }
    
    private func checkResult() {
        guard let userGuess = userGuess,
              let coinResult = coinResult else {
            isWinner = false
            return
        }
        
        isWinner = userGuess == coinResult
        
        if !isWinner {
            resetGame()
        }
    }
}
