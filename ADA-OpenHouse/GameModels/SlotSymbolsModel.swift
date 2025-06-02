//
//  SlotSymbolsModel.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 27/05/25.
//

import SwiftUI

enum SlotSymbolsModel: String, CaseIterable {
    case cherry = "🍒"
    case lemon = "🍋"
    case diamond = "💎"
    case seven = "7️⃣"
    
    static var allSymbols: [SlotSymbolsModel] {
        return SlotSymbolsModel.allCases
    }
    
    var jackpotReward: Int {
        switch self {
        case .cherry: return 100
        case .lemon: return 200
        case .diamond: return 500
        case .seven: return 1000
        }
    }
}
