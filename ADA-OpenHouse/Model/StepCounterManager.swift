//
//  StepCounterManager.swift
//  ADA-OpenHouse
//
//  Created by Medhiko Biraja on 20/05/25.
//

import CoreMotion
import Combine
import SwiftUI

class StepCounterManager {
    private let pedometer = CMPedometer()
    
    @Published var steps = 0
    
    func stepCount() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        
        pedometer.startUpdates(from: Date()) {[weak self] data, error in
            DispatchQueue.main.async {
                if let stepData = data {
                    self?.steps = stepData.numberOfSteps.intValue
                } else {
                    print("Pedometer error: \(error?.localizedDescription ?? "")")
                }
            }
        }
        
    }
    
    func resetSteps() {
        steps = 0
    }
    
    func stopCountingSteps() {
        pedometer.stopUpdates()
    }
}
