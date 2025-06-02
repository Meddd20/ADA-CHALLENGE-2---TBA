//
//  ProgressModel.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 02/06/25.
//

import Foundation
import SwiftData

@Model
class GameViewState {
    var id: UUID = UUID()
    var type: String
    var isDone: Bool
    
    init(type: GameViewType, isDone: Bool) {
        self.type = type.rawValue
        self.isDone = isDone
    }
}

@Model
class TagViewState {
    var id: UUID = UUID()
    var tag: String
    var isDone: Bool
    
    init(tag: String, isDone: Bool) {
        self.tag = tag
        self.isDone = isDone
    }
}

enum GameViewType: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }
    
    case punch, flip, recorder, compass, ballBalancing, cameraExpression, rockPaperScissors, wordle, slotMachine, cubeShaper, speechRecognition, anomaly, catMeowMimic, coinFlip
}

func upsertGameViewState(type: GameViewType, isDone: Bool, context: ModelContext) {
    // Try to fetch existing object with matching type
    let descriptor = FetchDescriptor<GameViewState>(
        predicate: #Predicate { $0.type == type.rawValue }
    )
    
    if let existing = try? context.fetch(descriptor).first {
        // Found existing -> update it
        existing.isDone = isDone
    } else {
        // Not found -> insert new object
        let newState = GameViewState(type: type, isDone: isDone)
        context.insert(newState)
    }
    
    // Save (optional depending on when/how your app saves)
    do {
        try context.save()
    } catch {
        print("Failed to save context: \(error)")
    }
}

func upsertTagViewState(tag: String, isDone: Bool, context: ModelContext) {
    let descriptor = FetchDescriptor<TagViewState>(
        predicate: #Predicate { $0.tag == tag }
    )
    
    if let existing = try? context.fetch(descriptor).first {
        existing.isDone = isDone
    } else {
        let newState = TagViewState(tag: tag, isDone: isDone)
        context.insert(newState)
    }
    try? context.save()
}
