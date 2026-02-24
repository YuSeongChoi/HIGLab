# Core Haptics AI Reference

> Haptic feedback implementation guide. Read this document to generate Core Haptics code.

## Overview

Core Haptics is a framework for creating and playing custom haptic (vibration) patterns.
It provides rich tactile experiences for games, notifications, and UI feedback.

## Required Import

```swift
import CoreHaptics
```

## Core Components

### 1. Haptic Engine Setup

```swift
class HapticManager {
    private var engine: CHHapticEngine?
    
    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Haptics not supported on this device")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Engine reset handler
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            
            // Engine stopped handler
            engine?.stoppedHandler = { reason in
                print("Engine stopped: \(reason)")
            }
        } catch {
            print("Haptic engine initialization failed: \(error)")
        }
    }
}
```

### 2. Simple UIKit Haptics

```swift
// Simplest method (UIKit)
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()

// Styles: .light, .medium, .heavy, .soft, .rigid

// Notification haptic
let notification = UINotificationFeedbackGenerator()
notification.notificationOccurred(.success)  // .success, .warning, .error

// Selection haptic
let selection = UISelectionFeedbackGenerator()
selection.selectionChanged()
```

## Complete Working Example

```swift
import SwiftUI
import CoreHaptics

// MARK: - Haptic Manager
@Observable
class HapticManager {
    private var engine: CHHapticEngine?
    var supportsHaptics: Bool
    
    init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        setupEngine()
    }
    
    private func setupEngine() {
        guard supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            
            try engine?.start()
        } catch {
            print("Haptic engine setup failed: \(error)")
        }
    }
    
    // MARK: - Basic Haptics
    func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Custom Haptic Patterns
    func playCustomPattern() {
        guard let engine else { return }
        
        do {
            // Define events
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            
            // Tap event
            let tap = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensity],
                relativeTime: 0
            )
            
            // Continuous vibration
            let continuous = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [sharpness, intensity],
                relativeTime: 0.1,
                duration: 0.3
            )
            
            let pattern = try CHHapticPattern(events: [tap, continuous], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Custom haptic playback failed: \(error)")
        }
    }
    
    // Heartbeat pattern
    func playHeartbeat() {
        guard let engine else { return }
        
        do {
            var events: [CHHapticEvent] = []
            
            for beat in 0..<4 {
                let time = Double(beat) * 0.6
                
                // Strong beat
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                    ],
                    relativeTime: time
                ))
                
                // Weak beat (0.15 seconds later)
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: time + 0.15
                ))
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Heartbeat haptic failed: \(error)")
        }
    }
    
    // Success pattern
    func playSuccess() {
        guard let engine else { return }
        
        do {
            let events = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                    ],
                    relativeTime: 0
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: 0.1
                )
            ]
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Success haptic failed: \(error)")
        }
    }
    
    // Error pattern
    func playError() {
        guard let engine else { return }
        
        do {
            var events: [CHHapticEvent] = []
            
            for i in 0..<3 {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                    ],
                    relativeTime: Double(i) * 0.1
                ))
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Error haptic failed: \(error)")
        }
    }
}

// MARK: - Views
struct HapticDemoView: View {
    @State private var haptic = HapticManager()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Basic Haptics") {
                    Button("Light Impact") {
                        haptic.playImpact(style: .light)
                    }
                    
                    Button("Medium Impact") {
                        haptic.playImpact(style: .medium)
                    }
                    
                    Button("Heavy Impact") {
                        haptic.playImpact(style: .heavy)
                    }
                    
                    Button("Selection") {
                        haptic.playSelection()
                    }
                }
                
                Section("Notification Haptics") {
                    Button("Success") {
                        haptic.playNotification(type: .success)
                    }
                    .tint(.green)
                    
                    Button("Warning") {
                        haptic.playNotification(type: .warning)
                    }
                    .tint(.orange)
                    
                    Button("Error") {
                        haptic.playNotification(type: .error)
                    }
                    .tint(.red)
                }
                
                Section("Custom Patterns") {
                    Button("Custom Pattern") {
                        haptic.playCustomPattern()
                    }
                    
                    Button("Heartbeat 💓") {
                        haptic.playHeartbeat()
                    }
                    
                    Button("Success ✓") {
                        haptic.playSuccess()
                    }
                    
                    Button("Error ✗") {
                        haptic.playError()
                    }
                }
                
                if !haptic.supportsHaptics {
                    Section {
                        Text("This device does not support haptics")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Haptic Demo")
        }
    }
}
```

## Advanced Patterns

### 1. Using AHAP Files

```swift
// Load AHAP (Apple Haptic Audio Pattern) file
func playFromFile(named filename: String) {
    guard let engine,
          let url = Bundle.main.url(forResource: filename, withExtension: "ahap") else { return }
    
    do {
        try engine.playPattern(from: url)
    } catch {
        print("AHAP playback failed: \(error)")
    }
}
```

**AHAP File Example (success.ahap)**:
```json
{
  "Version": 1.0,
  "Pattern": [
    {
      "Event": {
        "Time": 0.0,
        "EventType": "HapticTransient",
        "EventParameters": [
          {"ParameterID": "HapticIntensity", "ParameterValue": 0.8},
          {"ParameterID": "HapticSharpness", "ParameterValue": 0.4}
        ]
      }
    },
    {
      "Event": {
        "Time": 0.1,
        "EventType": "HapticTransient",
        "EventParameters": [
          {"ParameterID": "HapticIntensity", "ParameterValue": 1.0},
          {"ParameterID": "HapticSharpness", "ParameterValue": 0.6}
        ]
      }
    }
  ]
}
```

### 2. Real-time Parameter Control

```swift
func playWithDynamicControl() throws {
    guard let engine else { return }
    
    // Continuous vibration event
    let event = CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ],
        relativeTime: 0,
        duration: 2.0
    )
    
    // Dynamic parameter (changes over time)
    let curve = CHHapticParameterCurve(
        parameterID: .hapticIntensityControl,
        controlPoints: [
            CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.2),
            CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 1.0),
            CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.2)
        ],
        relativeTime: 0
    )
    
    let pattern = try CHHapticPattern(events: [event], parameterCurves: [curve])
    let player = try engine.makeAdvancedPlayer(with: pattern)
    try player.start(atTime: 0)
}
```

### 3. Audio and Haptic Synchronization

```swift
func playAudioHaptic() {
    guard let engine else { return }
    
    engine.playsHapticsOnly = false  // Also play audio
    
    do {
        let audioEvent = CHHapticEvent(
            eventType: .audioContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .audioVolume, value: 0.5)
            ],
            relativeTime: 0,
            duration: 1.0
        )
        
        let hapticEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
            ],
            relativeTime: 0,
            duration: 1.0
        )
        
        let pattern = try CHHapticPattern(events: [audioEvent, hapticEvent], parameters: [])
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: 0)
    } catch {
        print("Audio-haptic failed: \(error)")
    }
}
```

## Important Notes

1. **Check Device Support**
   ```swift
   CHHapticEngine.capabilitiesForHardware().supportsHaptics
   CHHapticEngine.capabilitiesForHardware().supportsAudio
   ```

2. **Engine Lifecycle**
   - Engine automatically stops when app goes to background
   - Handle restart in `resetHandler`

3. **Battery Considerations**
   - Excessive haptics drain battery
   - Recommend short, meaningful feedback

4. **Simulator Limitations**
   - Cannot experience haptics in simulator
   - Testing on real device required
