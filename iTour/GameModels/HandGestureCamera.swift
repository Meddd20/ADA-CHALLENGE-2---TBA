//
//  HandGestureCamera.swift
//  iTour
//
//  Created by Ramdan on 26/05/25.
//

import Foundation
import UIKit
import AVFoundation
import Vision
import SwiftUI

struct RPSResult {
    var confidence: Double?
    var identifier: String?
}

class RPSCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let session = AVCaptureSession()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    var frameCounter = 0
    var onGestureDetected: ((RPSResult) -> Void)?
    
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
        
        classifyGesture(pixelBuffer: pixelBuffer)
    }
    
    func classifyGesture(pixelBuffer: CVPixelBuffer) {
        do {
            let model = try RockScissorPaper(configuration: .init()).model
            let request = VNDetectHumanHandPoseRequest()
            request.maximumHandCount = 1
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
            try handler.perform([request])
            guard let observation = request.results?.first else {
                self.onGestureDetected?(RPSResult()) // empty
                return
            }
            
            let points = try observation.recognizedPoints(.all)
            
            guard let inputArray = createInputMultiArray(from: points) else {
                print("Failed to create input array")
                return
            }
            
            let input = RockScissorPaperInput(poses: inputArray)
            let output = try model.prediction(from: input)
            
            DispatchQueue.main.async {
                let confidence = output.featureValue(for: "labelProbabilities")?.dictionaryValue
                let label = output.featureValue(for: "label")?.stringValue ?? "None"
                self.onGestureDetected?(
                    RPSResult(
                        confidence: confidence?[label] as! Double? ?? 0.0,
                        identifier: label
                    )
                )
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createInputMultiArray(from points: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> MLMultiArray? {
        let orderedJoints: [VNHumanHandPoseObservation.JointName] = [
            .wrist,
            .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
        ]
        
        guard let mlArray = try? MLMultiArray(shape: [1, 3, 21], dataType: .float32) else { return nil }
        
        for (i, joint) in orderedJoints.enumerated() {
            if let point = points[joint] {
                mlArray[[0, 0, NSNumber(value: i)]] = NSNumber(value: Float(point.location.x)) // x
                mlArray[[0, 1, NSNumber(value: i)]] = NSNumber(value: Float(point.location.y)) // y
                mlArray[[0, 2, NSNumber(value: i)]] = NSNumber(value: Float(point.confidence))  // confidence or z
            } else {
                // If missing, fill with 0
                mlArray[[0, 0, NSNumber(value: i)]] = 0
                mlArray[[0, 1, NSNumber(value: i)]] = 0
                mlArray[[0, 2, NSNumber(value: i)]] = 0
            }
        }
        
        return mlArray
    }
}

//import SwiftUI
//import Vision

struct RPSCameraViewRepresentable: UIViewControllerRepresentable {
    @Binding var gesture: RPSResult?
    @Binding var isDone: Bool
    
    func makeUIViewController(context: Context) -> RPSCameraViewController {
        let controller = RPSCameraViewController()
        controller.onGestureDetected = { rpsResult in
            self.gesture = rpsResult
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: RPSCameraViewController, context: Context) {
        if isDone  {
            uiViewController.session.stopRunning()
        } else {
            if !uiViewController.session.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    uiViewController.session.startRunning()
                }
            }
        }
    }
}
