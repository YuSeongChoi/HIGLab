import CoreHaptics

// MARK: - Intensity (강도)와 Sharpness (선명도)

/*
 ┌─────────────────────────────────────────────────────┐
 │  Intensity (강도) 0.0 ~ 1.0                         │
 │  - 0.0: 매우 약한 진동 (거의 느껴지지 않음)         │
 │  - 0.5: 중간 강도                                   │
 │  - 1.0: 최대 강도                                   │
 └─────────────────────────────────────────────────────┘
 
 ┌─────────────────────────────────────────────────────┐
 │  Sharpness (선명도) 0.0 ~ 1.0                       │
 │  - 0.0: 둔탁하고 부드러운 느낌 (쿵)                 │
 │  - 0.5: 중간                                        │
 │  - 1.0: 날카롭고 선명한 느낌 (틱)                   │
 └─────────────────────────────────────────────────────┘
 */

// MARK: - 조합 예시

func createHapticPresets() throws -> [String: CHHapticPattern] {
    var presets: [String: CHHapticPattern] = [:]
    
    // 1. 부드러운 탭 (notification)
    presets["softTap"] = try createEvent(intensity: 0.5, sharpness: 0.2)
    
    // 2. 강한 클릭 (button press)
    presets["strongClick"] = try createEvent(intensity: 1.0, sharpness: 0.8)
    
    // 3. 둔탁한 충돌 (collision)
    presets["thud"] = try createEvent(intensity: 0.8, sharpness: 0.1)
    
    // 4. 선명한 탭 (toggle)
    presets["crispTap"] = try createEvent(intensity: 0.6, sharpness: 1.0)
    
    return presets
}

private func createEvent(intensity: Float, sharpness: Float) throws -> CHHapticPattern {
    let event = CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        ],
        relativeTime: 0
    )
    return try CHHapticPattern(events: [event], parameters: [])
}
