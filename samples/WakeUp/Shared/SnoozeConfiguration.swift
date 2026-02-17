// SnoozeConfiguration.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 스누즈 설정 모델

import Foundation
import AlarmKit

// MARK: - 스누즈 설정

/// 알람 스누즈 동작 설정
public struct SnoozeConfiguration: Codable, Sendable, Hashable {
    
    // MARK: - 속성
    
    /// 스누즈 활성화 여부
    public var isEnabled: Bool
    
    /// 스누즈 간격 (분)
    public var durationMinutes: Int
    
    /// 최대 스누즈 횟수
    public var maxCount: Int
    
    // MARK: - 초기화
    
    public init(
        isEnabled: Bool = true,
        durationMinutes: Int = 9,
        maxCount: Int = 3
    ) {
        self.isEnabled = isEnabled
        self.durationMinutes = durationMinutes
        self.maxCount = maxCount
    }
    
    // MARK: - 프리셋
    
    /// 기본 스누즈 설정 (9분, 3회)
    public static let `default` = SnoozeConfiguration(
        isEnabled: true,
        durationMinutes: 9,
        maxCount: 3
    )
    
    /// 짧은 스누즈 (5분, 2회)
    public static let short = SnoozeConfiguration(
        isEnabled: true,
        durationMinutes: 5,
        maxCount: 2
    )
    
    /// 긴 스누즈 (15분, 5회)
    public static let long = SnoozeConfiguration(
        isEnabled: true,
        durationMinutes: 15,
        maxCount: 5
    )
    
    /// 스누즈 비활성화
    public static let disabled = SnoozeConfiguration(
        isEnabled: false,
        durationMinutes: 9,
        maxCount: 0
    )
    
    // MARK: - 사용 가능한 옵션들
    
    /// 스누즈 간격 옵션 (분)
    public static let availableDurations: [Int] = [1, 3, 5, 9, 10, 15, 20, 30]
    
    /// 최대 횟수 옵션
    public static let availableMaxCounts: [Int] = [1, 2, 3, 5, 10, .max]
    
    // MARK: - 표시 문자열
    
    /// 스누즈 설정 요약 문자열
    public var summary: String {
        if !isEnabled {
            return "스누즈 꺼짐"
        }
        
        let countText = maxCount == .max ? "무제한" : "\(maxCount)회"
        return "\(durationMinutes)분 간격, \(countText)"
    }
    
    /// 스누즈 간격 표시 문자열
    public var durationText: String {
        "\(durationMinutes)분"
    }
    
    /// 최대 횟수 표시 문자열
    public var maxCountText: String {
        maxCount == .max ? "무제한" : "\(maxCount)회"
    }
}

// MARK: - 스누즈 프리셋

/// 미리 정의된 스누즈 설정 프리셋
public enum SnoozePreset: String, CaseIterable, Identifiable {
    case standard = "standard"
    case short = "short"
    case long = "long"
    case disabled = "disabled"
    case custom = "custom"
    
    public var id: String { rawValue }
    
    /// 프리셋 표시 이름
    public var displayName: String {
        switch self {
        case .standard: return "표준"
        case .short: return "짧게"
        case .long: return "길게"
        case .disabled: return "사용 안 함"
        case .custom: return "사용자 설정"
        }
    }
    
    /// 프리셋 설명
    public var description: String {
        switch self {
        case .standard: return "9분 간격, 최대 3회"
        case .short: return "5분 간격, 최대 2회"
        case .long: return "15분 간격, 최대 5회"
        case .disabled: return "스누즈 버튼 없음"
        case .custom: return "직접 설정"
        }
    }
    
    /// 프리셋 아이콘
    public var iconName: String {
        switch self {
        case .standard: return "clock.fill"
        case .short: return "hare.fill"
        case .long: return "tortoise.fill"
        case .disabled: return "xmark.circle.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    /// 프리셋에 해당하는 설정 반환
    public var configuration: SnoozeConfiguration {
        switch self {
        case .standard: return .default
        case .short: return .short
        case .long: return .long
        case .disabled: return .disabled
        case .custom: return .default // 사용자가 직접 수정
        }
    }
    
    /// 설정에 맞는 프리셋 찾기
    public static func preset(for config: SnoozeConfiguration) -> SnoozePreset {
        if !config.isEnabled {
            return .disabled
        }
        
        if config.durationMinutes == 9 && config.maxCount == 3 {
            return .standard
        } else if config.durationMinutes == 5 && config.maxCount == 2 {
            return .short
        } else if config.durationMinutes == 15 && config.maxCount == 5 {
            return .long
        } else {
            return .custom
        }
    }
}
