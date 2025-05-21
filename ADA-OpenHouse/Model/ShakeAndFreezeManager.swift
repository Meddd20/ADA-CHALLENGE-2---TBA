//
//  ShakeAndFreezeManager.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 22/05/25.
//

import CoreMotion
import Combine

class ShakeAndFreezeManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var isPhoneShake = false
    @Published var isPhoneFreeze = true
    @Published var start
    
    func startShakeAndFreeze() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        
    }
}
