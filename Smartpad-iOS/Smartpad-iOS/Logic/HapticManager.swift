//
//  HapticManager.swift
//  Smartpad-iOS
//
//  Created by Alireza Azimi on 2022-03-08.
//

import Foundation
import CoreHaptics

/**
 * Class responsible for playing haptic events.
 *
 * Required for haptics functional requirements (FR13 & FR14)
 */

// Source consulted: https://www.raywenderlich.com/10608020-getting-started-with-core-haptics
class HapticManager {
  let hapticEngine: CHHapticEngine

  init?() {
    let hapticCapability = CHHapticEngine.capabilitiesForHardware()
    guard hapticCapability.supportsHaptics else {
      return nil
    }

    do {
      hapticEngine = try CHHapticEngine()
    } catch let error {
      print("Haptic engine Creation Error: \(error)")
      return nil
    }
  }
}

extension HapticManager {
    private func touchDownPattern() throws -> CHHapticPattern {
        let snap = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
          ],
          relativeTime: 0) // Play immediately

        return try CHHapticPattern(events: [snap], parameters: [])
    }
    
    private func touchReleasePattern() throws -> CHHapticPattern {
        let snap = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
          ],
          relativeTime: 0) // Play immediately

        return try CHHapticPattern(events: [snap], parameters: [])
    }
    
    func playTouchDown() {
        do {
            let pattern = try touchDownPattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
              return .stopEngine
            }
        } catch {
            print("Failed to play slice: \(error)")
        }
    }
    
    func playTouchRelease() {
        do {
            let pattern = try touchReleasePattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
              return .stopEngine
            }
        } catch {
            print("Failed to play slice: \(error)")
        }
    }
}
