import CoreHaptics

// MARK: - Transient 햅틱 이벤트

/// 순간적인 탭 느낌의 햅틱
/// 버튼 클릭, 토글 스위치, 충돌 효과에 적합

func createTransientEvent() -> CHHapticEvent {
    // 파라미터 설정
    let intensity = CHHapticEventParameter(
        parameterID: .hapticIntensity,
        value: 1.0  // 0.0 ~ 1.0
    )
    
    let sharpness = CHHapticEventParameter(
        parameterID: .hapticSharpness,
        value: 0.5  // 0.0 ~ 1.0
    )
    
    // Transient 이벤트 생성
    let event = CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [intensity, sharpness],
        relativeTime: 0  // 즉시 실행
    )
    
    return event
}

// MARK: - Transient 연속 재생

func createMultipleTransients() throws -> CHHapticPattern {
    var events: [CHHapticEvent] = []
    
    // 0.1초 간격으로 3번 탭
    for i in 0..<3 {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: Double(i) * 0.1
        )
        events.append(event)
    }
    
    return try CHHapticPattern(events: events, parameters: [])
}
