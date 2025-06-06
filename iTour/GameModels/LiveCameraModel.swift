//
//  LiveCameraModel.swift
//  iTour
//
//  Created by Ramdan on 24/05/25.
//

import Foundation
import UIKit
import AVFoundation
import Mentalist

class LiveCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let session = AVCaptureSession()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    var frameCounter = 0
    var onEmotionDetected: ((Emotion) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup camera input
        session.sessionPreset = .high
            
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTripleCamera, .builtInTrueDepthCamera], mediaType: .video, position: .front).devices.first,
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ Failed to access front camera")
            return
        }
        
        
        if device.isFocusModeSupported(.continuousAutoFocus) {
            do {
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
            } catch {
                print("⚠️ Could not configure autofocus: \(error)")
            }
        }
        
        if device.isExposureModeSupported(.continuousAutoExposure) {
            do {
                try device.lockForConfiguration()
                device.exposureMode = .continuousAutoExposure
                device.unlockForConfiguration()
            } catch {
                print("⚠️ Could not configure autoexposure: \(error)")
            }
        }

        session.addInput(input)

        // Setup preview layer
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        // Setup output
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        session.addOutput(output)

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCounter += 1
        if frameCounter % 10 != 0 { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)

        do {
            let results = try Mentalist.analyze(uiImage: uiImage)
            if let emotion = results.first?.dominantEmotion {
                DispatchQueue.main.async {
                    self.onEmotionDetected?(emotion)
                }
            }
        } catch {
            print("Analysis error: \(error)")
        }
    }
}

import SwiftUI

struct CameraViewRepresentable: UIViewControllerRepresentable {
    @Binding var emotion: Emotion
    @Binding var isDone: Bool

    func makeUIViewController(context: Context) -> LiveCameraViewController {
        let controller = LiveCameraViewController()
        controller.onEmotionDetected = { detectedEmotion in
            self.emotion = detectedEmotion
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: LiveCameraViewController, context: Context) {
        if isDone {
            uiViewController.session.stopRunning()
        }
    }
}
