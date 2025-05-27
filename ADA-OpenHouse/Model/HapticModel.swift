//
//  HapticModel.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 20/05/25.
//

import Foundation
import CoreHaptics

class HapticModel: ObservableObject {
    private var hapticEngine: CHHapticEngine?
    
    let hapticDict = [
        CHHapticPattern.Key.pattern: [
            [CHHapticPattern.Key.event: [
                CHHapticPattern.Key.eventType: CHHapticEvent.EventType.hapticTransient,
                CHHapticPattern.Key.time: CHHapticTimeImmediate,
                CHHapticPattern.Key.eventDuration: 1.0]
            ]
        ]
    ]
    
    func startHapticEngine() {
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.resetHandler = self.resetHandler
            hapticEngine?.stoppedHandler = self.stopHandler
            try hapticEngine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    func resetHandler() {
        print("Reset Handler: Restarting the engine.")
        do {
            // Try restarting the engine.
            try self.hapticEngine?.start()
            // Register any custom resources you had registered, using registerAudioResource.
            // Recreate all haptic pattern players you had created, using createPlayer.
        } catch {
            fatalError("Failed to restart the engine: \(error)")
        }
    }
    
    func stopHandler(reason: CHHapticEngine.StoppedReason)  {
        print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
        switch reason {
        case .audioSessionInterrupt: print("Audio session interrupt")
        case .applicationSuspended: print("Application suspended")
        case .idleTimeout: print("Idle timeout")
        case .systemError: print("System error")
        case .notifyWhenFinished: print("Notify when finished")
        case .engineDestroyed: print("Engine destroyed")
        case .gameControllerDisconnect: print("Game controller disconnect")
        @unknown default:
            print("Unknown error")
        }
    }
    
    func playHaptic(duration: Double = 1) {
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: duration)
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
    
    deinit {
        hapticEngine?.stop()
    }
    
    init() {
        startHapticEngine()
    }
    
    
}
