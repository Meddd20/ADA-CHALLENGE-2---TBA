//
//  TextToSpeechModel.swift
//  iTour
//
//  Created by Ramdan on 28/05/25.
//

import Foundation
import AVFoundation

class TextToSpeechModel: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    let session = AVAudioSession.sharedInstance()

    func speak(_ text: String, language: String = "en-US") {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        guard !text.isEmpty else { return }
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)

        let utterance = AVSpeechUtterance(string: text)

        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            try? session.setActive(false)
        }
    }
}

func cleanWords(from sentence: String) -> [String] {
    let cleaned = sentence.lowercased()
        .components(separatedBy: .punctuationCharacters).joined()
        .trimmingCharacters(in: .whitespacesAndNewlines)
    return cleaned.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
}

func areSentencesSimilar(_ a: String, _ b: String, allowedWordErrors: Int = 1) -> Bool {
    let wordsA = cleanWords(from: a)
    let wordsB = cleanWords(from: b)

    // If lengths are equal, compare word by word
    if wordsA.count == wordsB.count {
        let mismatches = zip(wordsA, wordsB).filter { $0 != $1 }.count
        return mismatches <= allowedWordErrors
    }

    // If lengths differ, allow insert/delete up to allowedWordErrors using edit distance
    return wordEditDistance(wordsA, wordsB) <= allowedWordErrors
}

func wordEditDistance(_ a: [String], _ b: [String]) -> Int {
    let m = a.count
    let n = b.count
    var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

    for i in 0...m {
        for j in 0...n {
            if i == 0 {
                dp[i][j] = j
            } else if j == 0 {
                dp[i][j] = i
            } else if a[i - 1] == b[j - 1] {
                dp[i][j] = dp[i - 1][j - 1]
            } else {
                dp[i][j] = 1 + min(
                    dp[i - 1][j],    // deletion
                    dp[i][j - 1],    // insertion
                    dp[i - 1][j - 1] // substitution
                )
            }
        }
    }

    return dp[m][n]
}
