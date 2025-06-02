//
//  SentenceGenerator.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 28/05/25.
//

import Foundation

struct SentenceGenerator {
    let subjects = [
        "The cat", "A programmer", "My friend", "The robot", "An artist", "The teacher",
        "A scientist", "The musician", "An explorer", "The engineer", "A philosopher", "The chef"
    ]
    
    let adjectives = [
        "quick", "lazy", "brilliant", "curious", "happy", "tired", "clever",
        "dedicated", "mysterious", "insightful", "ambitious", "creative", "thoughtful"
    ]
    
    let verbs = [
        "eats", "writes", "builds", "draws", "explores", "analyzes", "plays",
        "creates", "invents", "studies", "narrates", "investigates", "solves"
    ]
    
    let adverbs = [
        "quickly", "silently", "happily", "sadly", "eagerly", "gracefully",
        "methodically", "enthusiastically", "intensely", "reluctantly"
    ]
    
    let objects = [
        "a pizza", "some code", "a spaceship", "a masterpiece", "the world", "a theory",
        "a song", "a puzzle", "an idea", "a problem", "an algorithm", "a story"
    ]
    
    let prepositionalPhrases = [
        "in the garden", "at the park", "on the roof", "under the stars", "near the river",
        "inside the lab", "beside the ocean", "above the clouds", "in a quiet library"
    ]
    
    let extraClauses = [
        "because they are inspired by a dream",
        "while thinking about the future",
        "as the sun sets in the distance",
        "despite the heavy rain",
        "even though it's late at night",
        "with a determined heart",
        "without any hesitation"
    ]

    func generate() -> String {
        let subject = subjects.randomElement() ?? "Someone"
        let adjective = Bool.random() ? (adjectives.randomElement() ?? "") : ""
        let verb = verbs.randomElement() ?? "does"
        let adverb = Bool.random() ? (adverbs.randomElement() ?? "") : ""
        let object = objects.randomElement() ?? "something"
        let prepositionalPhrase = Bool.random() ? (prepositionalPhrases.randomElement() ?? "") : ""
        let extraClause = Bool.random() ? (extraClauses.randomElement() ?? "") : ""

        let subjectPhrase = adjective.isEmpty ? subject : "\(subject) who is \(adjective)"
        let adverbPhrase = adverb.isEmpty ? "" : " \(adverb)"
        let prepPhrase = prepositionalPhrase.isEmpty ? "" : " \(prepositionalPhrase)"
        let clause = extraClause.isEmpty ? "" : ", \(extraClause)"

        return "\(subjectPhrase) \(verb)\(adverbPhrase) \(object)\(prepPhrase)\(clause)."
    }
}
