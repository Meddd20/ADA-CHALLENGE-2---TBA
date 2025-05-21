//
//  CompassModle.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 21/05/25.
//

import Foundation
import CoreLocation

let targetDegree = Double.random(in: 0...360)

class CompassModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var timer: Timer?
    private var tolerance: Double = 5.0
    private var holdTime = 0.0
    
    @Published var success: Bool = false
    @Published var heading: Double = 0.0
    @Published var grace: Bool = false
    @Published var arc = targetDegree
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        arc = targetDegree
        
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func overrideArc(_ value: Double) {
        arc = value
    }
    
    func overrideTolerance(_ value: Double) {
        tolerance = value
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading // or use .trueHeading if needed
        checkHeading()
    }
    
    private func checkHeading() {
        let isWithinTarget = abs(heading - arc) <= tolerance
        grace = isWithinTarget
        
        if isWithinTarget {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        
        holdTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return }
            
            self.holdTime += 1
            
            if self.holdTime >= 3 {
                self.success = true
                self.stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        if !success {
            holdTime = 0
        }
    }
}
