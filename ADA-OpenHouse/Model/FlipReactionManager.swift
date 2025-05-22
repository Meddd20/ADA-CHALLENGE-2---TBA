//
//  FlipReactionManager.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 21/05/25.
//

import CoreMotion
import Foundation

class FlipReactionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private var queue = OperationQueue()
    
    @Published var isPhoneFaceDown = false
    
    func detectFlipReaction() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
            guard let motion = motion, let self = self else { return }
            
            DispatchQueue.main.async {
                self.isPhoneFaceDown = motion.gravity.z > 0.8
            }
        }
    }
    
    func stopDetectFlipReaction() {
        motionManager.stopDeviceMotionUpdates()
    }
}
