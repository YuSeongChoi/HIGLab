// HapticPattern.swift
// HapticDemo - Core Haptics 샘플
// 햅틱 패턴을 정의하는 모델

import Foundation
import CoreHaptics

// MARK: - 햅틱 이벤트 타입
/// 지원하는 햅틱 이벤트 종류
enum HapticEventType: String, CaseIterable, Codable, Identifiable {
    case transient = "일시적"      // 짧고 날카로운 진동
    case continuous = "연속적"     // 지속되는 진동
    case audioContinuous = "오디오 연속"  // 오디오와 함께
    case audioCustom = "오디오 커스텀"    // 커스텀 오디오
    
    var id: String { rawValue }
    
    /// Core Haptics 이벤트 타입으로 변환
    var chEventType: CHHapticEvent.EventType {
        switch self {
        case .transient: return .hapticTransient
        case .continuous: return .hapticContinuous
        case .audioContinuous: return .audioContinuous
        case .audioCustom: return .audioCustom
        }
    }
    
    /// 아이콘 이름
    var iconName: String {
        switch self {
        case .transient: return "bolt.fill"
        case .continuous: return "waveform"
        case .audioContinuous: return "speaker.wave.2.fill"
        case .audioCustom: return "music.note"
        }
    }
}

// MARK: - 햅틱 이벤트 모델
/// 단일 햅틱 이벤트를 나타내는 구조체
struct HapticEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var type: HapticEventType
    var relativeTime: TimeInterval    // 패턴 시작 후 발생 시간
    var duration: TimeInterval        // 지속 시간 (연속 타입에만 적용)
    var intensity: Float              // 강도 (0.0 ~ 1.0)
    var sharpness: Float              // 선명도 (0.0 ~ 1.0)
    
    init(
        id: UUID = UUID(),
        type: HapticEventType = .transient,
        relativeTime: TimeInterval = 0,
        duration: TimeInterval = 0.1,
        intensity: Float = 1.0,
        sharpness: Float = 0.5
    ) {
        self.id = id
        self.type = type
        self.relativeTime = relativeTime
        self.duration = duration
        self.intensity = intensity
        self.sharpness = sharpness
    }
    
    /// CHHapticEvent로 변환
    func toCHHapticEvent() -> CHHapticEvent {
        let parameters: [CHHapticEventParameter] = [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        ]
        
        return CHHapticEvent(
            eventType: type.chEventType,
            parameters: parameters,
            relativeTime: relativeTime,
            duration: type == .transient ? 0 : duration
        )
    }
}

// MARK: - 햅틱 패턴 모델
/// 여러 이벤트로 구성된 햅틱 패턴
struct HapticPattern: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var events: [HapticEvent]
    var isLooping: Bool               // 반복 재생 여부
    var loopDuration: TimeInterval    // 전체 루프 길이
    
    init(
        id: UUID = UUID(),
        name: String = "새 패턴",
        description: String = "",
        events: [HapticEvent] = [],
        isLooping: Bool = false,
        loopDuration: TimeInterval = 1.0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.events = events
        self.isLooping = isLooping
        self.loopDuration = loopDuration
    }
    
    /// 패턴의 총 지속 시간 계산
    var totalDuration: TimeInterval {
        guard !events.isEmpty else { return 0 }
        return events.map { $0.relativeTime + $0.duration }.max() ?? 0
    }
    
    /// CHHapticPattern으로 변환
    func toCHHapticPattern() throws -> CHHapticPattern {
        let chEvents = events.map { $0.toCHHapticEvent() }
        return try CHHapticPattern(events: chEvents, parameters: [])
    }
    
    /// 시간순으로 정렬된 이벤트 반환
    var sortedEvents: [HapticEvent] {
        events.sorted { $0.relativeTime < $1.relativeTime }
    }
}

// MARK: - 다이나믹 파라미터 모델
/// 실시간으로 변경 가능한 파라미터
struct DynamicParameter: Identifiable, Codable {
    let id: UUID
    var parameterType: DynamicParameterType
    var value: Float
    var relativeTime: TimeInterval
    
    init(
        id: UUID = UUID(),
        parameterType: DynamicParameterType = .intensity,
        value: Float = 1.0,
        relativeTime: TimeInterval = 0
    ) {
        self.id = id
        self.parameterType = parameterType
        self.value = value
        self.relativeTime = relativeTime
    }
}

/// 다이나믹 파라미터 타입
enum DynamicParameterType: String, CaseIterable, Codable {
    case intensity = "강도"
    case sharpness = "선명도"
    case attackTime = "어택 시간"
    case decayTime = "디케이 시간"
    case releaseTime = "릴리즈 시간"
    
    var chParameterID: CHHapticDynamicParameter.ID {
        switch self {
        case .intensity: return .hapticIntensityControl
        case .sharpness: return .hapticSharpnessControl
        case .attackTime: return .hapticAttackTimeControl
        case .decayTime: return .hapticDecayTimeControl
        case .releaseTime: return .hapticReleaseTimeControl
        }
    }
}

// MARK: - 패턴 카테고리
/// 프리셋 패턴 분류
enum PatternCategory: String, CaseIterable, Codable, Identifiable {
    case basic = "기본"
    case notification = "알림"
    case game = "게임"
    case interaction = "인터랙션"
    case custom = "커스텀"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .basic: return "circle.grid.2x2.fill"
        case .notification: return "bell.fill"
        case .game: return "gamecontroller.fill"
        case .interaction: return "hand.tap.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    var color: String {
        switch self {
        case .basic: return "blue"
        case .notification: return "orange"
        case .game: return "purple"
        case .interaction: return "green"
        case .custom: return "pink"
        }
    }
}
