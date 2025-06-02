//
//  CatPredictionManager.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 01/06/25.
//

import SoundAnalysis
import AVFoundation
import Combine

class SoundPredictionManager: NSObject, ObservableObject, SNResultsObserving {
    private var analyzer: SNAudioStreamAnalyzer?
    private let analysisQueue = DispatchQueue(label: "SoundPredictionQueue")
    private var request: SNClassifySoundRequest?
    
    private var catDetectedStartTime: Date?
    var isConfirmCat = false

    @Published var predictionLabel: String = ""
    @Published var predictionConfidence: Double = 0.0

    override init() {
        super.init()
    }

    func configure(with format: AVAudioFormat) {
        guard format.sampleRate > 0, format.channelCount > 0 else {
            print("❌ Invalid format.")
            return
        }

        analyzer = SNAudioStreamAnalyzer(format: format)

        if let model = try? MimicAnimalSound(configuration: .init()) {
            request = try? SNClassifySoundRequest(mlModel: model.model)
            if let request = request {
                try? analyzer?.add(request, withObserver: self)
            }
        }
    }

    func analyze(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard let analyzer = analyzer else {
            print("⚠️ Analyzer not available")
            return
        }
        analysisQueue.async {
            analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let top = result.classifications.first else { return }

        DispatchQueue.main.async {
            print("Confidence Level: \(top.confidence)")
            if top.identifier == "cat" && top.confidence > 0.8 {
                if self.catDetectedStartTime == nil {
                    self.catDetectedStartTime = Date()
                }

                let duration = Date().timeIntervalSince(self.catDetectedStartTime!)
                if duration >= 0.8 && !self.isConfirmCat {
                    self.predictionLabel = "cat"
                    self.predictionConfidence = top.confidence
                    self.isConfirmCat = true
                }
            } else {
                self.catDetectedStartTime = nil
                if self.isConfirmCat {
                    self.predictionLabel = ""
                    self.predictionConfidence = 0.0
                    self.isConfirmCat = false
                }
            }
        }
    }


    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("❌ ML Error: \(error.localizedDescription)")
    }
}
