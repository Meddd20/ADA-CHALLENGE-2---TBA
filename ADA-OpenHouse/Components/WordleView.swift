//
//  WordleView.swift
//  Worlde
//
//  Created by Wira Wibisana on 27/05/25.
//
import SwiftUI
import CoreHaptics

struct WordleView: View {
    var body: some View {
        WordleGameView()
    }
}

struct WordleGameView: View {
    @StateObject private var gameModel: WordleGame
    @StateObject var haptics = HapticModel()

    init() {
        _gameModel = StateObject(wrappedValue: WordleGame())
    }

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

class WordleGame: ObservableObject {
    @Published var board: [[Character?]] = Array(repeating: Array(repeating: nil, count: 5), count: 6)
    @Published var currentRow = 0
    @Published var currentCol = 0
    @Published var gameOver = false
    @Published var showingAlert = false
    @Published var alertMessage = ""

    private var targetWord = ""
    private var letterStates: [Character: KeyState] = [:]
    @StateObject var haptics = HapticModel()

    
    // Curated list of common 5-letter words for better preview performance
    private let wordList = [
        "ABOUT", "ABOVE", "ABUSE", "ACTOR", "ACUTE", "ADMIT", "ADOPT", "ADULT", "AFTER", "AGAIN",
        "AGENT", "AGREE", "AHEAD", "ALARM", "ALBUM", "ALERT", "ALIEN", "ALIGN", "ALIKE", "ALIVE",
        "ALLOW", "ALONE", "ALONG", "ALTER", "ANGEL", "ANGER", "ANGLE", "ANGRY", "APART", "APPLE",
        "APPLY", "ARENA", "ARGUE", "ARISE", "ARRAY", "ARROW", "ASIDE", "ASSET", "AUDIO", "AUDIT",
        "AVOID", "AWAKE", "AWARD", "AWARE", "BADLY", "BAKER", "BASES", "BASIC", "BEACH", "BEGAN",
        "BEGIN", "BEING", "BELOW", "BENCH", "BIRTH", "BLACK", "BLAME", "BLANK", "BLIND", "BLOCK",
        "BLOOD", "BOARD", "BOOST", "BOOTH", "BOUND", "BRAIN", "BRAND", "BRAVE", "BREAD", "BREAK",
        "BREED", "BRIEF", "BRING", "BROAD", "BROKE", "BROWN", "BUILD", "BUILT", "BUYER", "CABLE",
        "CARRY", "CATCH", "CAUSE", "CHAIN", "CHAIR", "CHAOS", "CHARM", "CHART", "CHASE", "CHEAP",
        "CHECK", "CHEST", "CHIEF", "CHILD", "CHINA", "CHOSE", "CIVIC", "CIVIL", "CLAIM", "CLASS",
        "CLEAN", "CLEAR", "CLICK", "CLIMB", "CLOCK", "CLOSE", "CLOUD", "COACH", "COAST", "COULD",
        "COUNT", "COURT", "COVER", "CRAFT", "CRASH", "CRAZY", "CREAM", "CRIME", "CROSS", "CROWD",
        "CROWN", "CRUDE", "CURVE", "CYCLE", "DAILY", "DANCE", "DATED", "DEALT", "DEATH", "DEBUG",
        "DELAY", "DEPTH", "DOING", "DOUBT", "DOZEN", "DRAFT", "DRAMA", "DRANK", "DREAM", "DRESS",
        "DRILL", "DRINK", "DRIVE", "DROVE", "DYING", "EAGER", "EARLY", "EARTH", "EIGHT", "ELITE",
        "EMPTY", "ENEMY", "ENJOY", "ENTER", "ENTRY", "EQUAL", "ERROR", "EVENT", "EVERY", "EXACT",
        "EXIST", "EXTRA", "FAITH", "FALSE", "FAULT", "FIBER", "FIELD", "FIFTH", "FIFTY", "FIGHT",
        "FINAL", "FIRST", "FIXED", "FLASH", "FLEET", "FLOOR", "FLUID", "FOCUS", "FORCE", "FORTH",
        "FORTY", "FORUM", "FOUND", "FRAME", "FRANK", "FRAUD", "FRESH", "FRONT", "FRUIT", "FULLY",
        "FUNNY", "GIANT", "GIVEN", "GLASS", "GLOBE", "GOING", "GRACE", "GRADE", "GRAND", "GRANT",
        "GRASS", "GRAVE", "GREAT", "GREEN", "GROSS", "GROUP", "GROWN", "GUARD", "GUESS", "GUEST",
        "GUIDE", "HAPPY", "HEART", "HEAVY", "HORSE", "HOTEL", "HOUSE", "HUMAN", "HURRY", "IMAGE",
        "INDEX", "INNER", "INPUT", "ISSUE", "JOINT", "JUDGE", "KNOWN", "LABEL", "LARGE", "LASER",
        "LATER", "LAUGH", "LAYER", "LEARN", "LEASE", "LEAST", "LEAVE", "LEGAL", "LEVEL", "LIGHT",
        "LIMIT", "LINKS", "LIVES", "LOCAL", "LOOSE", "LOWER", "LUCKY", "LUNCH", "LYING", "MAGIC",
        "MAJOR", "MAKER", "MARCH", "MATCH", "MAYBE", "MAYOR", "MEANT", "MEDIA", "METAL", "MIGHT",
        "MINOR", "MINUS", "MIXED", "MODEL", "MONEY", "MONTH", "MORAL", "MOTOR", "MOUNT", "MOUSE",
        "MOUTH", "MOVED", "MOVIE", "MUSIC", "NEEDS", "NERVE", "NEVER", "NEWLY", "NIGHT", "NOISE",
        "NORTH", "NOTED", "NOVEL", "NURSE", "OCCUR", "OCEAN", "OFFER", "OFTEN", "ORDER", "OTHER",
        "OUGHT", "PAINT", "PANEL", "PAPER", "PARTY", "PEACE", "PHASE", "PHONE", "PHOTO", "PIANO",
        "PIECE", "PILOT", "PITCH", "PLACE", "PLAIN", "PLANE", "PLANT", "PLATE", "POINT", "POUND",
        "POWER", "PRESS", "PRICE", "PRIDE", "PRIME", "PRINT", "PRIOR", "PRIZE", "PROOF", "PROUD",
        "PROVE", "QUEEN", "QUICK", "QUIET", "QUITE", "RADIO", "RAISE", "RANGE", "RAPID", "RATIO",
        "REACH", "READY", "REALM", "REBEL", "REFER", "RELAX", "REPAY", "REPLY", "RIGHT", "RIGID",
        "RIVAL", "RIVER", "ROBIN", "ROGER", "ROMAN", "ROUGH", "ROUND", "ROUTE", "ROYAL", "RURAL",
        "SCALE", "SCENE", "SCOPE", "SCORE", "SENSE", "SERVE", "SETUP", "SEVEN", "SHALL", "SHAPE",
        "SHARE", "SHARP", "SHEET", "SHELF", "SHELL", "SHIFT", "SHINE", "SHIRT", "SHOCK", "SHOOT",
        "SHORT", "SHOWN", "SIGHT", "SINCE", "SIXTH", "SIXTY", "SIZED", "SKILL", "SLEEP", "SLIDE",
        "SMALL", "SMART", "SMILE", "SMITH", "SMOKE", "SOLID", "SOLVE", "SORRY", "SOUND", "SOUTH",
        "SPACE", "SPARE", "SPEAK", "SPEED", "SPEND", "SPENT", "SPLIT", "SPOKE", "SPORT", "STAFF",
        "STAGE", "STAKE", "STAND", "START", "STATE", "STEAM", "STEEL", "STEEP", "STEER", "STICK",
        "STILL", "STOCK", "STONE", "STOOD", "STORE", "STORM", "STORY", "STRIP", "STUCK", "STUDY",
        "STUFF", "STYLE", "SUGAR", "SUITE", "SUPER", "SWEET", "TABLE", "TAKEN", "TASTE", "TAXES",
        "TEACH", "TEETH", "THANK", "THEFT", "THEIR", "THEME", "THERE", "THESE", "THICK", "THING",
        "THINK", "THIRD", "THOSE", "THREE", "THREW", "THROW", "THUMB", "TIGER", "TIGHT", "TIMER",
        "TODAY", "TOPIC", "TOTAL", "TOUCH", "TOUGH", "TOWER", "TRACK", "TRADE", "TRAIN", "TREAT",
        "TREND", "TRIAL", "TRIBE", "TRICK", "TRIED", "TRIES", "TRUCK", "TRULY", "TRUNK", "TRUST",
        "TRUTH", "TWICE", "TWIST", "TYPES", "UNCLE", "UNCUT", "UNION", "UNITY", "UNTIL", "UPPER",
        "UPSET", "URBAN", "USAGE", "USUAL", "VALID", "VALUE", "VIDEO", "VIRUS", "VISIT", "VITAL",
        "VOCAL", "VOICE", "WASTE", "WATCH", "WATER", "WHEEL", "WHERE", "WHICH", "WHILE", "WHITE",
        "WHOLE", "WHOSE", "WOMAN", "WOMEN", "WORLD", "WORRY", "WORSE", "WORST", "WORTH", "WOULD",
        "WRITE", "WRONG", "WROTE", "YOUNG", "YOUTH"
    ]
    
    init() {
        newGame()
        setupHaptics()
    }
    
    private func setupHaptics() {
        // In a real app, you'd initialize UIFeedbackGenerator here
        // For preview, we'll just add comments about haptic usage
    }
    
    func newGame() {
        board = Array(repeating: Array(repeating: nil, count: 5), count: 6)
        currentRow = 0
        currentCol = 0
        gameOver = false
        showingAlert = false
        alertMessage = ""
        letterStates.removeAll()
        targetWord = wordList.randomElement() ?? "WORLD"
        print("Target word: \(targetWord)") // For debugging
    }
    
    func addLetter(_ letter: String) {
        guard !gameOver && currentCol < 5 else { return }
        
        // Haptic feedback would go here: selectionFeedback.selectionChanged()
        
        board[currentRow][currentCol] = Character(letter)
        currentCol += 1
    }
    
    func deleteLetter() {
        guard !gameOver && currentCol > 0 else { return }
        
        // Haptic feedback would go here: impactFeedback.impactOccurred(intensity: 0.5)
        
        currentCol -= 1
        board[currentRow][currentCol] = nil
    }
    
    func submitGuess() {
        guard !gameOver && currentCol == 5 else { return }

        let guess = String(board[currentRow].compactMap { $0 })

        // Skip dictionary validation — accept any 5-letter word

        // Haptic feedback would go here: impactFeedback.impactOccurred()

        // Update letter states
        updateLetterStates(for: guess)

        // Check if won
        if guess == targetWord {
            gameOver = true
            alertMessage = "Congratulations! You found the word!"
            showingAlert = true
            haptics.playHaptic()
            // Haptic feedback would go here: notificationFeedback.notificationOccurred(.success)
            return
        }

        // Move to next row
        currentRow += 1
        currentCol = 0

        // Check if lost
        if currentRow >= 6 {
            gameOver = true
            alertMessage = "You lost! The word was \(targetWord)"
            showingAlert = true
            // Haptic feedback would go here: notificationFeedback.notificationOccurred(.error)
        }
    }
    
    private func updateLetterStates(for guess: String) {
        let guessArray = Array(guess)
        let targetArray = Array(targetWord)
        
        for (index, letter) in guessArray.enumerated() {
            if targetArray[index] == letter {
                letterStates[letter] = .correct
            } else if targetArray.contains(letter) && letterStates[letter] != .correct {
                letterStates[letter] = .wrongPosition
            } else if letterStates[letter] == nil {
                letterStates[letter] = .incorrect
            }
        }
    }
    
    func getCellState(row: Int, col: Int) -> CellState {
        guard row < currentRow else {
            return board[row][col] == nil ? .empty : .filled
        }
        
        guard let letter = board[row][col] else { return .empty }
        
        let targetArray = Array(targetWord)
        
        if targetArray[col] == letter {
            return .correct
        } else if targetArray.contains(letter) {
            return .wrongPosition
        } else {
            return .incorrect
        }
    }
    
    func getKeyState(_ letter: String) -> KeyState {
        return letterStates[Character(letter)] ?? .unused
    }
}

// MARK: - Preview
#Preview {
    WordleView()
}
