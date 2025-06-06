//
//  SimonSaysViewController.swift
//  iTour
//
//  Created by Medhiko Biraja on 03/06/25.
//

import Foundation
import UIKit
import AVFoundation
import Vision

class SimonSaysCamera: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    var frameCounter = 0
    var onEmotionDetected: ((String, Double) -> Void)?
    
    var poseBuffer: [[VNRecognizedPoint?]] = []
    let sequenceLength = 60
    
    let orderedJoints: [VNHumanBodyPoseObservation.JointName] = [
        .nose, .leftEye, .rightEye, .leftEar, .rightEar,
        .leftShoulder, .rightShoulder,
        .leftElbow, .rightElbow,
        .leftWrist, .rightWrist,
        .leftHip, .rightHip,
        .leftKnee, .rightKnee,
        .leftAnkle, .rightAnkle,
        .root
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Debug every 30 frames to avoid spam
        let shouldDebug = frameCounter % 30 == 0
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            if shouldDebug { print("❌ No pixel buffer") }
            return
        }

        do {
            let request = VNDetectHumanBodyPoseRequest()
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored) // Changed orientation
            try handler.perform([request])
            
            guard let observation = request.results?.first else {
                if shouldDebug { print("⚠️ No pose observations") }
                return
            }
            
            let points = try observation.recognizedPoints(.all)
            if shouldDebug {
                print("👤 Detected \(points.count) joints")
                // Check if we have key joints
                let keyJoints = [VNHumanBodyPoseObservation.JointName.nose, .leftShoulder, .rightShoulder]
                for joint in keyJoints {
                    if let point = points[joint] {
                        print("  \(joint): confidence \(point.confidence)")
                    }
                }
            }

            // Add to buffer
            let currentFrame = orderedJoints.map { points[$0] }
            poseBuffer.append(currentFrame)

            // Keep only last 60
            if poseBuffer.count > sequenceLength {
                poseBuffer.removeFirst()
            }

            if shouldDebug {
                print("📊 Buffer size: \(poseBuffer.count)/\(sequenceLength)")
            }

            // Only run prediction when we have enough
            if poseBuffer.count == sequenceLength {
                if shouldDebug { print("🚀 Running prediction...") }
                
                guard let inputArray = createBufferedMultiArray(from: poseBuffer) else {
                    print("❌ Failed to create input array")
                    return
                }

                do {
                    let model = try SimonSays(configuration: .init()).model
                    let input = SimonSaysInput(poses: inputArray)
                    let output = try model.prediction(from: input)
                    
                    // Debug output
                    print("🎯 Model output keys: \(output.featureNames)")
                    
                    let label = output.featureValue(for: "label")?.stringValue ?? "Unknown"
                    let probabilities = output.featureValue(for: "labelProbabilities")?.dictionaryValue
                    
                    print("📝 Predicted label: \(label)")
                    print("🎲 All probabilities: \(String(describing: probabilities))")
                    
                    let confidence = probabilities?[label] as? Double ?? 0.0
                    
                    print("✅ Final: \(label) with confidence \(confidence)")
                    
                    DispatchQueue.main.async {
                        self.onEmotionDetected?(label, confidence)
                    }
                } catch {
                    print("❌ Model prediction error: \(error)")
                }
            }
            
        } catch {
            print("❌ Vision request error: \(error)")
        }
    }
    
    func createBufferedMultiArray(from buffer: [[VNRecognizedPoint?]]) -> MLMultiArray? {
        let jointCount = 18
        guard let mlArray = try? MLMultiArray(shape: [60, 3, NSNumber(value: jointCount)], dataType: .float32) else {
            return nil
        }

        for frameIdx in 0..<buffer.count {
            let joints = buffer[frameIdx]
            for jointIdx in 0..<min(joints.count, jointCount) {
                let point = joints[jointIdx]

                let x = Float(point?.location.x ?? 0)
                let y = Float(point?.location.y ?? 0)
                let confidence = Float(point?.confidence ?? 0)

                mlArray[[NSNumber(value: frameIdx), 0, NSNumber(value: jointIdx)]] = NSNumber(value: x)
                mlArray[[NSNumber(value: frameIdx), 1, NSNumber(value: jointIdx)]] = NSNumber(value: y)
                mlArray[[NSNumber(value: frameIdx), 2, NSNumber(value: jointIdx)]] = NSNumber(value: confidence)
            }
        }

        return mlArray
    }
}
