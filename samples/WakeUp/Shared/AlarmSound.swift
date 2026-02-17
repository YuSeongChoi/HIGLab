// AlarmSound.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 알람 사운드 설정 모델

import Foundation
import AlarmKit

// MARK: - 알람 사운드

/// 알람 사운드 종류
/// AlarmKit의 AlarmSound와 매핑됨
public enum AlarmSound: String, CaseIterable, Codable, Sendable, Identifiable {
    
    // MARK: - 기본 사운드
    
    /// 일출 - 점점 밝아지는 느낌의 알람음
    case sunrise = "sunrise"
    
    /// 활기찬 - 에너지 넘치는 알람음
    case energetic = "energetic"
    
    /// 부드러운 - 조용하고 부드러운 알람음
    case gentle = "gentle"
    
    /// 자연 - 새소리, 물소리 등 자연음
    case nature = "nature"
    
    /// 클래식 - 전통적인 알람음
    case classic = "classic"
    
    /// 디지털 - 현대적인 디지털 알람음
    case digital = "digital"
    
    /// 멜로디 - 음악적인 멜로디
    case melody = "melody"
    
    /// 레이더 - 강렬한 레이더 스타일
    case radar = "radar"
    
    /// 진동만 - 소리 없이 진동만
    case vibrationOnly = "vibration_only"
    
    /// 무음 - 소리와 진동 없음
    case silent = "silent"
    
    // MARK: - Identifiable
    
    public var id: String { rawValue }
    
    // MARK: - 속성
    
    /// 사운드 표시 이름
    public var displayName: String {
        switch self {
        case .sunrise: return "일출"
        case .energetic: return "활기찬 아침"
        case .gentle: return "부드러운 기상"
        case .nature: return "자연의 소리"
        case .classic: return "클래식 알람"
        case .digital: return "디지털"
        case .melody: return "멜로디"
        case .radar: return "레이더"
        case .vibrationOnly: return "진동만"
        case .silent: return "무음"
        }
    }
    
    /// 사운드 설명
    public var description: String {
        switch self {
        case .sunrise:
            return "점점 밝아지며 부드럽게 깨워주는 알람"
        case .energetic:
            return "활기찬 시작을 위한 에너지 넘치는 알람"
        case .gentle:
            return "조용히 깨워주는 부드러운 알람"
        case .nature:
            return "새소리와 물소리로 자연스럽게 기상"
        case .classic:
            return "전통적인 알람 벨 소리"
        case .digital:
            return "현대적인 디지털 알람음"
        case .melody:
            return "아름다운 멜로디로 기분 좋은 기상"
        case .radar:
            return "놓치지 않는 강렬한 알람"
        case .vibrationOnly:
            return "소리 없이 진동으로만 알림"
        case .silent:
            return "소리와 진동 없이 화면만 표시"
        }
    }
    
    /// 아이콘 이름 (SF Symbols)
    public var iconName: String {
        switch self {
        case .sunrise: return "sunrise.fill"
        case .energetic: return "bolt.fill"
        case .gentle: return "leaf.fill"
        case .nature: return "bird.fill"
        case .classic: return "bell.fill"
        case .digital: return "waveform"
        case .melody: return "music.note"
        case .radar: return "dot.radiowaves.left.and.right"
        case .vibrationOnly: return "iphone.gen3.radiowaves.left.and.right"
        case .silent: return "speaker.slash.fill"
        }
    }
    
    /// 진동 포함 여부
    public var hasVibration: Bool {
        switch self {
        case .silent:
            return false
        default:
            return true
        }
    }
    
    /// 소리 포함 여부
    public var hasSound: Bool {
        switch self {
        case .vibrationOnly, .silent:
            return false
        default:
            return true
        }
    }
    
    /// 카테고리별 그룹화
    public var category: SoundCategory {
        switch self {
        case .sunrise, .gentle, .nature:
            return .calm
        case .energetic, .radar:
            return .intense
        case .classic, .digital, .melody:
            return .standard
        case .vibrationOnly, .silent:
            return .special
        }
    }
    
    // MARK: - AlarmKit 변환
    
    /// AlarmKit의 AlarmSound로 변환
    @available(iOS 26.0, *)
    public func toAlarmKitSound() -> AlarmDescriptor.Sound {
        switch self {
        case .sunrise:
            return .named("Sunrise")
        case .energetic:
            return .named("Energetic")
        case .gentle:
            return .named("Gentle")
        case .nature:
            return .named("Nature")
        case .classic:
            return .named("Classic")
        case .digital:
            return .named("Digital")
        case .melody:
            return .named("Melody")
        case .radar:
            return .named("Radar")
        case .vibrationOnly:
            return .vibrationOnly
        case .silent:
            return .none
        }
    }
}

// MARK: - 사운드 카테고리

/// 사운드 분류 카테고리
public enum SoundCategory: String, CaseIterable, Identifiable {
    case calm = "calm"
    case standard = "standard"
    case intense = "intense"
    case special = "special"
    
    public var id: String { rawValue }
    
    /// 카테고리 표시 이름
    public var displayName: String {
        switch self {
        case .calm: return "차분한 알람"
        case .standard: return "일반 알람"
        case .intense: return "강한 알람"
        case .special: return "특수 알람"
        }
    }
    
    /// 카테고리에 속한 사운드 목록
    public var sounds: [AlarmSound] {
        AlarmSound.allCases.filter { $0.category == self }
    }
}

// MARK: - 사운드 그룹화 헬퍼

extension AlarmSound {
    
    /// 카테고리별로 그룹화된 사운드 딕셔너리
    public static var groupedByCategory: [SoundCategory: [AlarmSound]] {
        Dictionary(grouping: AlarmSound.allCases) { $0.category }
    }
    
    /// 순서대로 정렬된 카테고리 배열
    public static var orderedCategories: [SoundCategory] {
        [.calm, .standard, .intense, .special]
    }
}
