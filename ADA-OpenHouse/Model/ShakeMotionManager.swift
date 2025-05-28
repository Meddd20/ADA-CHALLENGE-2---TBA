//
//  ShakeMotionManger.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 19/05/25.
//

import CoreMotion
import Combine
import SwiftUI

class ShakeMotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var didShakeDetected = false
    
    func detectShakeMotion() {
        guard motionManager.isAccelerometerAvailable else { return }
                
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
            guard let data = data, let self = self else { return }
            
            let acc = data.acceleration
            let magnitude = sqrt(acc.x * acc.x + acc.y * acc.y)
            
            DispatchQueue.main.async {
                if magnitude >= 6.0 && !self.didShakeDetected {
                    self.didShakeDetected = true
                    print("Shake Detected")
                    
                    self.stopShakeDetection()
                }
            }
        }
    }
    
    func stopShakeDetection() {
        self.motionManager.stopAccelerometerUpdates()
    }
    
    func resetShakeDetection() {
        didShakeDetected = false
    }
}
