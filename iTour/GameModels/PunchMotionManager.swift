//
//  PunchMotionManager.swift
//  iTour
//
//  Created by Medhiko Biraja on 20/05/25.
//

import CoreMotion
import Combine

class PunchMotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private let haptic = HapticModel()
    
    @Published var didPunchDetected = false
    @Published var peakAcceleration = 0.0
    
    func detectPunchingMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        motionManager.startDeviceMotionUpdates(to: queue) {[weak self] data, error in
            guard let data = data, let self = self else { return }
            
            let acc = data.userAcceleration
            let magnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)
            
            DispatchQueue.main.async {
                if magnitude > self.peakAcceleration  {
                    self.peakAcceleration = magnitude
                    print(self.peakAcceleration)
                }
                
                if magnitude >= 7.0 && !self.didPunchDetected {
                    self.didPunchDetected = true
                    self.haptic.playHaptic(duration: 0.7)
                }
            }
        }
    }
    
    func resetPeakPunch() {
        peakAcceleration = 0.0
        didPunchDetected = false
    }
    
    func stopDetectMotion() {
        motionManager.stopDeviceMotionUpdates()
    }
}
