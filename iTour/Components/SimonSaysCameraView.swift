//
//  SimonSaysCamera.swift
//  iTour
//
//  Created by Medhiko Biraja on 03/06/25.
//

import Foundation
import SwiftUI

struct SimonSaysCameraView: UIViewControllerRepresentable {
    @Binding var resultLabel: String
    @Binding var confidence: Double
    @Binding var isDone: Bool

    func makeUIViewController(context: Context) -> SimonSaysCamera {
        let controller = SimonSaysCamera()
        controller.onEmotionDetected = { label, conf in
            self.resultLabel = label
            self.confidence = conf
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: SimonSaysCamera, context: Context) {
        if isDone {
            uiViewController.session.stopRunning()
        } else if !uiViewController.session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                uiViewController.session.startRunning()
            }
        }
    }
}
