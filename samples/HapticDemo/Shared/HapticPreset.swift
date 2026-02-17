// HapticPreset.swift
// HapticDemo - Core Haptics 샘플
// 미리 정의된 햅틱 프리셋 모음

import Foundation

// MARK: - 햅틱 프리셋
/// 미리 정의된 햅틱 패턴과 메타데이터
struct HapticPreset: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let category: PatternCategory
    let pattern: HapticPattern
    let iconName: String
    let previewColor: String
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        category: PatternCategory,
        pattern: HapticPattern,
        iconName: String = "waveform",
        previewColor: String = "blue"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.pattern = pattern
        self.iconName = iconName
        self.previewColor = previewColor
    }
}

// MARK: - 기본 프리셋 라이브러리
/// 앱에서 제공하는 기본 프리셋들
struct PresetLibrary {
    
    // MARK: - 기본 패턴
    
    /// 단일 탭 - 가장 기본적인 일시적 햅틱
    static let singleTap = HapticPreset(
        name: "싱글 탭",
        description: "가볍고 빠른 한 번의 진동",
        category: .basic,
        pattern: HapticPattern(
            name: "싱글 탭",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.8, sharpness: 0.5)
            ]
        ),
        iconName: "hand.tap",
        previewColor: "blue"
    )
    
    /// 더블 탭 - 두 번의 연속 탭
    static let doubleTap = HapticPreset(
        name: "더블 탭",
        description: "두 번의 짧은 진동",
        category: .basic,
        pattern: HapticPattern(
            name: "더블 탭",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.7, sharpness: 0.5),
                HapticEvent(type: .transient, relativeTime: 0.1, intensity: 0.7, sharpness: 0.5)
            ]
        ),
        iconName: "hand.tap.fill",
        previewColor: "blue"
    )
    
    /// 트리플 탭 - 세 번의 연속 탭
    static let tripleTap = HapticPreset(
        name: "트리플 탭",
        description: "세 번의 리듬감 있는 진동",
        category: .basic,
        pattern: HapticPattern(
            name: "트리플 탭",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.6, sharpness: 0.5),
                HapticEvent(type: .transient, relativeTime: 0.1, intensity: 0.7, sharpness: 0.5),
                HapticEvent(type: .transient, relativeTime: 0.2, intensity: 0.8, sharpness: 0.5)
            ]
        ),
        iconName: "3.circle.fill",
        previewColor: "blue"
    )
    
    // MARK: - 알림 패턴
    
    /// 성공 알림 - 긍정적인 피드백
    static let success = HapticPreset(
        name: "성공",
        description: "작업 완료를 알리는 상승하는 진동",
        category: .notification,
        pattern: HapticPattern(
            name: "성공",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.5, sharpness: 0.3),
                HapticEvent(type: .transient, relativeTime: 0.1, intensity: 0.7, sharpness: 0.5),
                HapticEvent(type: .transient, relativeTime: 0.2, intensity: 1.0, sharpness: 0.8)
            ]
        ),
        iconName: "checkmark.circle.fill",
        previewColor: "green"
    )
    
    /// 경고 알림 - 주의를 끄는 패턴
    static let warning = HapticPreset(
        name: "경고",
        description: "주의가 필요할 때 사용하는 강한 진동",
        category: .notification,
        pattern: HapticPattern(
            name: "경고",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 1.0, sharpness: 1.0),
                HapticEvent(type: .transient, relativeTime: 0.15, intensity: 1.0, sharpness: 1.0),
                HapticEvent(type: .transient, relativeTime: 0.3, intensity: 1.0, sharpness: 1.0)
            ]
        ),
        iconName: "exclamationmark.triangle.fill",
        previewColor: "orange"
    )
    
    /// 오류 알림 - 실패를 알리는 패턴
    static let error = HapticPreset(
        name: "오류",
        description: "실패나 오류 상황을 알리는 진동",
        category: .notification,
        pattern: HapticPattern(
            name: "오류",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 1.0, sharpness: 0.8),
                HapticEvent(type: .continuous, relativeTime: 0.1, duration: 0.2, intensity: 0.6, sharpness: 0.3),
                HapticEvent(type: .transient, relativeTime: 0.35, intensity: 0.8, sharpness: 0.6)
            ]
        ),
        iconName: "xmark.circle.fill",
        previewColor: "red"
    )
    
    /// 알림 도착
    static let notification = HapticPreset(
        name: "알림",
        description: "새로운 알림 도착을 알리는 패턴",
        category: .notification,
        pattern: HapticPattern(
            name: "알림",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.7, sharpness: 0.6),
                HapticEvent(type: .transient, relativeTime: 0.08, intensity: 0.5, sharpness: 0.4)
            ]
        ),
        iconName: "bell.badge.fill",
        previewColor: "orange"
    )
    
    // MARK: - 게임 패턴
    
    /// 충돌 효과
    static let impact = HapticPreset(
        name: "충돌",
        description: "강력한 충격 효과",
        category: .game,
        pattern: HapticPattern(
            name: "충돌",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 1.0, sharpness: 1.0),
                HapticEvent(type: .continuous, relativeTime: 0.02, duration: 0.15, intensity: 0.5, sharpness: 0.2)
            ]
        ),
        iconName: "burst.fill",
        previewColor: "purple"
    )
    
    /// 폭발 효과
    static let explosion = HapticPreset(
        name: "폭발",
        description: "점점 약해지는 폭발 진동",
        category: .game,
        pattern: HapticPattern(
            name: "폭발",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 1.0, sharpness: 1.0),
                HapticEvent(type: .continuous, relativeTime: 0.02, duration: 0.3, intensity: 0.8, sharpness: 0.4),
                HapticEvent(type: .transient, relativeTime: 0.1, intensity: 0.6, sharpness: 0.6),
                HapticEvent(type: .transient, relativeTime: 0.2, intensity: 0.4, sharpness: 0.4),
                HapticEvent(type: .transient, relativeTime: 0.3, intensity: 0.2, sharpness: 0.2)
            ]
        ),
        iconName: "flame.fill",
        previewColor: "red"
    )
    
    /// 점프 효과
    static let jump = HapticPreset(
        name: "점프",
        description: "캐릭터 점프 시 피드백",
        category: .game,
        pattern: HapticPattern(
            name: "점프",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.6, sharpness: 0.8),
                HapticEvent(type: .transient, relativeTime: 0.05, intensity: 0.3, sharpness: 0.4)
            ]
        ),
        iconName: "arrow.up.circle.fill",
        previewColor: "cyan"
    )
    
    /// 착지 효과
    static let landing = HapticPreset(
        name: "착지",
        description: "캐릭터 착지 시 피드백",
        category: .game,
        pattern: HapticPattern(
            name: "착지",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.8, sharpness: 0.6),
                HapticEvent(type: .continuous, relativeTime: 0.02, duration: 0.1, intensity: 0.3, sharpness: 0.2)
            ]
        ),
        iconName: "arrow.down.circle.fill",
        previewColor: "brown"
    )
    
    /// 아이템 획득
    static let collectItem = HapticPreset(
        name: "아이템 획득",
        description: "아이템을 얻었을 때의 기분 좋은 피드백",
        category: .game,
        pattern: HapticPattern(
            name: "아이템 획득",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.4, sharpness: 0.6),
                HapticEvent(type: .transient, relativeTime: 0.06, intensity: 0.6, sharpness: 0.7),
                HapticEvent(type: .transient, relativeTime: 0.12, intensity: 0.8, sharpness: 0.8)
            ]
        ),
        iconName: "star.fill",
        previewColor: "yellow"
    )
    
    // MARK: - 인터랙션 패턴
    
    /// 버튼 누름
    static let buttonPress = HapticPreset(
        name: "버튼 누름",
        description: "물리적 버튼 느낌의 피드백",
        category: .interaction,
        pattern: HapticPattern(
            name: "버튼 누름",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.5, sharpness: 0.7)
            ]
        ),
        iconName: "button.programmable",
        previewColor: "green"
    )
    
    /// 슬라이더 눈금
    static let sliderTick = HapticPreset(
        name: "슬라이더 틱",
        description: "슬라이더 눈금 느낌",
        category: .interaction,
        pattern: HapticPattern(
            name: "슬라이더 틱",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.3, sharpness: 0.9)
            ]
        ),
        iconName: "slider.horizontal.3",
        previewColor: "teal"
    )
    
    /// 스위치 토글
    static let toggle = HapticPreset(
        name: "토글",
        description: "스위치 ON/OFF 피드백",
        category: .interaction,
        pattern: HapticPattern(
            name: "토글",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.6, sharpness: 0.5),
                HapticEvent(type: .transient, relativeTime: 0.05, intensity: 0.4, sharpness: 0.3)
            ]
        ),
        iconName: "switch.2",
        previewColor: "mint"
    )
    
    /// 스크롤 엣지
    static let scrollBounce = HapticPreset(
        name: "스크롤 바운스",
        description: "스크롤 끝에 도달했을 때",
        category: .interaction,
        pattern: HapticPattern(
            name: "스크롤 바운스",
            events: [
                HapticEvent(type: .continuous, relativeTime: 0, duration: 0.15, intensity: 0.4, sharpness: 0.3),
                HapticEvent(type: .transient, relativeTime: 0.15, intensity: 0.6, sharpness: 0.5)
            ]
        ),
        iconName: "arrow.up.arrow.down",
        previewColor: "indigo"
    )
    
    /// 롱 프레스
    static let longPress = HapticPreset(
        name: "롱프레스",
        description: "길게 누르기 인식 피드백",
        category: .interaction,
        pattern: HapticPattern(
            name: "롱프레스",
            events: [
                HapticEvent(type: .continuous, relativeTime: 0, duration: 0.2, intensity: 0.3, sharpness: 0.4),
                HapticEvent(type: .transient, relativeTime: 0.2, intensity: 0.7, sharpness: 0.6)
            ]
        ),
        iconName: "hand.point.down.fill",
        previewColor: "green"
    )
    
    // MARK: - 연속 패턴
    
    /// 하트비트 패턴
    static let heartbeat = HapticPreset(
        name: "심장 박동",
        description: "두근두근 심장 박동 패턴",
        category: .custom,
        pattern: HapticPattern(
            name: "심장 박동",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.8, sharpness: 0.3),
                HapticEvent(type: .transient, relativeTime: 0.15, intensity: 0.5, sharpness: 0.2),
                HapticEvent(type: .transient, relativeTime: 0.6, intensity: 0.8, sharpness: 0.3),
                HapticEvent(type: .transient, relativeTime: 0.75, intensity: 0.5, sharpness: 0.2)
            ],
            isLooping: true,
            loopDuration: 1.0
        ),
        iconName: "heart.fill",
        previewColor: "pink"
    )
    
    /// 진동 알람
    static let vibration = HapticPreset(
        name: "진동 알람",
        description: "연속적인 진동 패턴",
        category: .custom,
        pattern: HapticPattern(
            name: "진동 알람",
            events: [
                HapticEvent(type: .continuous, relativeTime: 0, duration: 0.2, intensity: 0.8, sharpness: 0.5),
                HapticEvent(type: .continuous, relativeTime: 0.3, duration: 0.2, intensity: 0.8, sharpness: 0.5),
                HapticEvent(type: .continuous, relativeTime: 0.6, duration: 0.2, intensity: 0.8, sharpness: 0.5)
            ],
            isLooping: true,
            loopDuration: 1.0
        ),
        iconName: "iphone.radiowaves.left.and.right",
        previewColor: "pink"
    )
    
    /// 레인드롭 패턴
    static let raindrops = HapticPreset(
        name: "빗방울",
        description: "불규칙한 빗방울 느낌",
        category: .custom,
        pattern: HapticPattern(
            name: "빗방울",
            events: [
                HapticEvent(type: .transient, relativeTime: 0, intensity: 0.3, sharpness: 0.8),
                HapticEvent(type: .transient, relativeTime: 0.12, intensity: 0.5, sharpness: 0.7),
                HapticEvent(type: .transient, relativeTime: 0.25, intensity: 0.2, sharpness: 0.9),
                HapticEvent(type: .transient, relativeTime: 0.4, intensity: 0.4, sharpness: 0.6),
                HapticEvent(type: .transient, relativeTime: 0.55, intensity: 0.6, sharpness: 0.8),
                HapticEvent(type: .transient, relativeTime: 0.7, intensity: 0.3, sharpness: 0.7),
                HapticEvent(type: .transient, relativeTime: 0.85, intensity: 0.5, sharpness: 0.9)
            ],
            isLooping: true,
            loopDuration: 1.0
        ),
        iconName: "cloud.rain.fill",
        previewColor: "cyan"
    )
    
    // MARK: - 전체 프리셋 목록
    
    /// 모든 프리셋을 카테고리별로 반환
    static var allPresets: [HapticPreset] {
        [
            // 기본
            singleTap, doubleTap, tripleTap,
            // 알림
            success, warning, error, notification,
            // 게임
            impact, explosion, jump, landing, collectItem,
            // 인터랙션
            buttonPress, sliderTick, toggle, scrollBounce, longPress,
            // 커스텀
            heartbeat, vibration, raindrops
        ]
    }
    
    /// 카테고리별 프리셋 필터링
    static func presets(for category: PatternCategory) -> [HapticPreset] {
        allPresets.filter { $0.category == category }
    }
}
