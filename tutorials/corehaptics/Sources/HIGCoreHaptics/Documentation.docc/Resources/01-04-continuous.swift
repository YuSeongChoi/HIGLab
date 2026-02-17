import CoreHaptics

// MARK: - Continuous 햅틱 이벤트

/// 일정 시간 지속되는 진동
/// 슬라이더 드래그, 로딩 상태, 엔진 소리에 적합

func createContinuousEvent() -> CHHapticEvent {
    let intensity = CHHapticEventParameter(
        parameterID: .hapticIntensity,
        value: 0.7
    )
    
    let sharpness = CHHapticEventParameter(
        parameterID: .hapticSharpness,
        value: 0.3
    )
    
    // Continuous 이벤트 (0.5초 지속)
    let event = CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: [intensity, sharpness],
        relativeTime: 0,
        duration: 0.5  // 지속 시간 (초)
    )
    
    return event
}

// MARK: - Continuous + 동적 파라미터

func createFadingContinuous() throws -> CHHapticPattern {
    // Continuous 이벤트 (1초)
    let event = CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ],
        relativeTime: 0,
        duration: 1.0
    )
    
    // 동적 파라미터: 강도 페이드아웃
    let fadeOut = CHHapticParameterCurve(
        parameterID: .hapticIntensityControl,
        controlPoints: [
            CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1.0),
            CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.0)
        ],
        relativeTime: 0
    )
    
    return try CHHapticPattern(
        events: [event],
        parameterCurves: [fadeOut]
    )
}
