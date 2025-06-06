//
//  WordleModel.swift
//  iTour
//
//  Created by Ramdan on 27/05/25.
//

import Foundation

class WordleGame: ObservableObject {
    @Published var board: [[Character?]] = Array(repeating: Array(repeating: nil, count: 5), count: 6)
    @Published var currentRow = 0
    @Published var currentCol = 0
    @Published var gameOver = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isWon = false
    
    var onComplete: (() -> Void)?
    
    private var targetWord = ""
    private var letterStates: [Character: KeyState] = [:]
    var haptics = HapticModel()
    
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
    
    func newGame() {
        board = Array(repeating: Array(repeating: nil, count: 5), count: 6)
        currentRow = 0
        currentCol = 0
        gameOver = false
        showingAlert = false
        alertMessage = ""
        letterStates.removeAll()
        targetWord = wordList.randomElement() ?? "WORLD"
        isWon = true
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
        
        // Update letter states
        updateLetterStates(for: guess)
        
        // Check if won
        if guess == targetWord {
            DispatchQueue.main.async {
                self.gameOver = true
                self.alertMessage = "Congratulations! You found the word!"
                self.showingAlert = true
                self.haptics.playHaptic()
                self.onComplete?()
            }
            
            return
        }
        
        // Move to next row
        currentRow += 1
        currentCol = 0
        
        // Check if lost
        if currentRow >= 6 {
            DispatchQueue.main.async {
                self.gameOver = true
                self.alertMessage = "You lost! The word was \(self.targetWord)"
                self.showingAlert = true
                self.haptics.playHaptic()
            }
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
