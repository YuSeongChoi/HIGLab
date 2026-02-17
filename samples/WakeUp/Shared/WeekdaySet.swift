// WeekdaySet.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 요일 집합 관리를 위한 모델

import Foundation
import AlarmKit

// MARK: - 요일 열거형

/// 요일을 나타내는 열거형
/// Calendar.weekday와 호환 (일요일 = 1)
public enum Weekday: Int, CaseIterable, Codable, Sendable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    public var id: Int { rawValue }
    
    /// 한글 요일명 (짧은 형식)
    public var shortName: String {
        switch self {
        case .sunday: return "일"
        case .monday: return "월"
        case .tuesday: return "화"
        case .wednesday: return "수"
        case .thursday: return "목"
        case .friday: return "금"
        case .saturday: return "토"
        }
    }
    
    /// 한글 요일명 (긴 형식)
    public var fullName: String {
        switch self {
        case .sunday: return "일요일"
        case .monday: return "월요일"
        case .tuesday: return "화요일"
        case .wednesday: return "수요일"
        case .thursday: return "목요일"
        case .friday: return "금요일"
        case .saturday: return "토요일"
        }
    }
    
    /// Calendar의 weekday 값으로 초기화
    public init?(calendarWeekday: Int) {
        self.init(rawValue: calendarWeekday)
    }
    
    /// AlarmKit 요일로 변환
    @available(iOS 26.0, *)
    public func toAlarmKitWeekday() -> AlarmDescriptor.Recurrence.Weekday {
        switch self {
        case .sunday: return .sunday
        case .monday: return .monday
        case .tuesday: return .tuesday
        case .wednesday: return .wednesday
        case .thursday: return .thursday
        case .friday: return .friday
        case .saturday: return .saturday
        }
    }
}

// MARK: - 요일 집합

/// 여러 요일을 담는 집합 타입
/// 반복 알람 설정에 사용
public struct WeekdaySet: OptionSet, Codable, Sendable, Hashable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    // MARK: - 개별 요일 옵션
    
    public static let sunday    = WeekdaySet(rawValue: 1 << 0)
    public static let monday    = WeekdaySet(rawValue: 1 << 1)
    public static let tuesday   = WeekdaySet(rawValue: 1 << 2)
    public static let wednesday = WeekdaySet(rawValue: 1 << 3)
    public static let thursday  = WeekdaySet(rawValue: 1 << 4)
    public static let friday    = WeekdaySet(rawValue: 1 << 5)
    public static let saturday  = WeekdaySet(rawValue: 1 << 6)
    
    // MARK: - 프리셋
    
    /// 평일 (월-금)
    public static let weekdays: WeekdaySet = [.monday, .tuesday, .wednesday, .thursday, .friday]
    
    /// 주말 (토-일)
    public static let weekends: WeekdaySet = [.saturday, .sunday]
    
    /// 매일
    public static let everyday: WeekdaySet = [
        .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday
    ]
    
    /// 모든 요일 배열
    public static let allWeekdays: [Weekday] = Weekday.allCases
    
    // MARK: - 변환 메서드
    
    /// Weekday 열거형으로 WeekdaySet 생성
    public init(_ weekday: Weekday) {
        self.rawValue = 1 << (weekday.rawValue - 1)
    }
    
    /// Weekday 배열로 WeekdaySet 생성
    public init(_ weekdays: [Weekday]) {
        var value = 0
        for weekday in weekdays {
            value |= 1 << (weekday.rawValue - 1)
        }
        self.rawValue = value
    }
    
    /// 특정 요일 포함 여부 확인
    public func contains(_ weekday: Weekday) -> Bool {
        self.contains(WeekdaySet(weekday))
    }
    
    /// 포함된 요일 배열 반환
    public var weekdays: [Weekday] {
        Weekday.allCases.filter { contains($0) }
    }
    
    /// 요일 토글
    public mutating func toggle(_ weekday: Weekday) {
        if contains(weekday) {
            remove(WeekdaySet(weekday))
        } else {
            insert(WeekdaySet(weekday))
        }
    }
    
    // MARK: - 표시 문자열
    
    /// 요일 요약 문자열
    public var summary: String {
        if self == .everyday {
            return "매일"
        } else if self == .weekdays {
            return "평일"
        } else if self == .weekends {
            return "주말"
        } else if isEmpty {
            return "반복 안 함"
        } else {
            // 선택된 요일들을 짧은 이름으로 나열
            let names = weekdays.map { $0.shortName }
            return names.joined(separator: ", ")
        }
    }
    
    /// 요일 상세 문자열 (긴 형식)
    public var detailedSummary: String {
        if self == .everyday {
            return "매일 반복"
        } else if self == .weekdays {
            return "평일 반복 (월-금)"
        } else if self == .weekends {
            return "주말 반복 (토-일)"
        } else if isEmpty {
            return "반복하지 않음"
        } else {
            let names = weekdays.map { $0.fullName }
            return names.joined(separator: ", ") + " 반복"
        }
    }
    
    // MARK: - AlarmKit 변환
    
    /// AlarmKit의 Weekday 집합으로 변환
    @available(iOS 26.0, *)
    public func toAlarmKitWeekdays() -> Set<AlarmDescriptor.Recurrence.Weekday> {
        Set(weekdays.map { $0.toAlarmKitWeekday() })
    }
}

// MARK: - ExpressibleByArrayLiteral

extension WeekdaySet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Weekday...) {
        self.init(elements)
    }
}
