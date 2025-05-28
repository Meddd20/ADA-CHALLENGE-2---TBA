//
//  WordleView.swift
//  Worlde
//
//  Created by Wira Wibisana on 27/05/25.
//
import SwiftUI

struct WordleGameView: View {
    @StateObject private var gameModel = WordleGame()
    @StateObject var haptics = HapticModel()
    var tagId: String
    
    @EnvironmentObject var navManager: NavigationManager<Routes>
    
    var body: some View {
        VStack(spacing: 20) { // This is the main VStack for all content
            // Title
            Text("WORLDE")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top)
            Text("Guess the random 5 letter words!")
            
            Spacer()
            
            // Game Grid
            WordleGrid(game: gameModel)
                .frame(maxWidth: 350)
            
            Spacer()
            
            // Custom Keyboard
            WordleKeyboard(game: gameModel, haptics: haptics)
                .frame(maxWidth: 350) // The keyboard itself will still respect this max width
        }
        .frame(maxWidth: 380, maxHeight: .infinity) // This ensures the VStack tries to fill space
        .background(Color(.systemBackground))
        .alert("Game Over", isPresented: $gameModel.showingAlert) {
            Button("Retry") {
                gameModel.newGame()
            }
        } message: {
            Text(gameModel.alertMessage)
        }
        .onAppear {
            gameModel.newGame()
            gameModel.onComplete = {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navManager.path = .init([.details(tagId: tagId)])                    
                }
            }
        }
    }
}

struct WordleGrid: View {
    @ObservedObject var game: WordleGame
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { col in
                        LetterCell(
                            letter: game.board[row][col],
                            state: game.getCellState(row: row, col: col)
                        )
                    }
                }
            }
        }
    }
}

struct LetterCell: View {
    let letter: Character?
    let state: CellState
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .border(borderColor, width: 2)
                .frame(width: 60, height: 60)
            
            if let letter = letter {
                Text(String(letter))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: state)
    }
    
    private var backgroundColor: Color {
        switch state {
        case .empty, .filled:
            return Color(.systemBackground)
        case .correct:
            return .green
        case .wrongPosition:
            return .orange
        case .incorrect:
            return .gray
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .empty:
            return Color(.systemGray4)
        case .filled:
            return Color(.systemGray2)
        case .correct, .wrongPosition, .incorrect:
            return backgroundColor
        }
    }
    
    private var textColor: Color {
        switch state {
        case .empty, .filled:
            return .primary
        case .correct, .wrongPosition, .incorrect:
            return .white
        }
    }
}

struct WordleKeyboard: View {
    @ObservedObject var game: WordleGame
    @StateObject var haptics = HapticModel()
    
    let topRow = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
    let middleRow = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
    let bottomRow = ["Z", "X", "C", "V", "B", "N", "M"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row
            HStack(spacing: 6) {
                ForEach(topRow, id: \.self) { letter in
                    KeyButton(letter: letter, game: game, haptics: haptics)
                }
            }
            
            // Middle row
            HStack(spacing: 6) {
                ForEach(middleRow, id: \.self) { letter in
                    KeyButton(letter: letter, game: game, haptics: haptics)
                }
            }
            
            // Bottom row
            HStack(spacing: 6) {
                // Enter button
                Button(action: {
                    haptics.playHaptic(duration: 0.1)
                    game.submitGuess()
                }) {
                    Text("return")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color(.blue))
                        .cornerRadius(6)
                }
                
                ForEach(bottomRow, id: \.self) { letter in
                    KeyButton(letter: letter, game: game, haptics: haptics)
                }
                
                // Delete button
                Button(action: {
                    haptics.playHaptic(duration: 0.1)
                    game.deleteLetter()
                }) {
                    Image(systemName: "delete.left")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color(.red))
                        .cornerRadius(6)
                }
            }
        }
    }
}


struct KeyButton: View {
    let letter: String
    @ObservedObject var game: WordleGame
    @StateObject var haptics = HapticModel()
    
    var body: some View {
        HStack {
            Button(action: {
                haptics.playHaptic(duration: 0.1)
                game.addLetter(letter)
            }) {
                Text(letter)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                    .frame(width:32, height: 50)
                    .background(backgroundColor)
                    .cornerRadius(6)
            }
        }
    }
    
    private var backgroundColor: Color {
        switch game.getKeyState(letter) {
        case .correct:
            return .green
        case .wrongPosition:
            return .orange
        case .incorrect:
            return .gray
        case .unused:
            return Color(.systemGray5)
        }
    }
    
    private var textColor: Color {
        switch game.getKeyState(letter) {
        case .correct, .wrongPosition, .incorrect:
            return .white
        case .unused:
            return .primary
        }
    }
}

enum CellState {
    case empty
    case filled
    case correct
    case wrongPosition
    case incorrect
}

enum KeyState {
    case unused
    case correct
    case wrongPosition
    case incorrect
}

// MARK: - Preview
#Preview {
    WordleGameView(tagId: "123")
}
