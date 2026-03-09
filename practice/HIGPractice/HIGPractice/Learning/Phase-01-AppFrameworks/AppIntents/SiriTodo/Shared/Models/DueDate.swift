//
//  DueDate.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/9/26.
//

import Foundation
import AppIntents

struct DueDate: Codable, Hashable, Sendable {
    let date: Date
    
    // MARK: - 초기화
    
    init(_ date: Date) {
        self.date = date
    }
    
    // MARK: - 편의 생성자
    
    /// 오늘 마감
    static var today: DueDate {
        DueDate(Calendar.current.startOfDay(for: Date()).addingTimeInterval(86399))
    }
    
    /// 내일 마감
    static var tomorrow: DueDate {
        DueDate(Calendar.current.date(byAdding: .day, value: 1, to: today.date)!)
    }
    
    /// 이번 주말 마감
    static var thisWeekend: DueDate {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 7 // 토요일
        return DueDate(calendar.date(from: components)!)
    }
    
    /// 다음 주 마감
    static var nextWeek: DueDate {
        DueDate(Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!)
    }
    
    /// 다음 달 마감
    static var nextMonth: DueDate {
        DueDate(Calendar.current.date(byAdding: .month, value: 1, to: Date())!)
    }
    
    // MARK: - 상태 확인
    
    /// 기한이 지났는지 확인
    var isOverdue: Bool {
        date < Date()
    }
    
    /// 오늘이 마감인지 확인
    var isDueToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// 내일이 마감인지 확인
    var isDueTomorrow: Bool {
        Calendar.current.isDateInTomorrow(date)
    }
    
    /// 이번 주 마감인지 확인
    var isDueThisWeek: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    // MARK: - 표시 문자열
    
    /// 상대적 시간 표시 (예: "2일 후", "3시간 전")
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    /// 날짜 문자열 (예: "2023년 10월 18일")
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// 짧은 날짜 문자열 (예: "5월 16일")
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return formatter.string(from: date)
    }
    
    /// 상태 이모지
    var statusEmoji: String {
        if isOverdue {
            return "⚠️"
        } else if isDueToday {
            return "📅"
        } else if isDueTomorrow {
            return "📆"
        } else {
            return "🗓️"
        }
    }
}

// MARK: - 마감일 프리셋 열거형
/// Siri에서 선택할 수 있는 마감일 프리셋
enum DueDatePreset: String, AppEnum, CaseIterable {
    case today = "today"
    case tomorrow = "tomorrow"
    case thisWeekend = "weekend"
    case nextWeek = "nextWeek"
    case nextMonth = "nextMonth"
    case none = "none"
    
    // MARK: - AppEnum 필수 구현
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "마감일")
    }
    
    static var caseDisplayRepresentations: [DueDatePreset : DisplayRepresentation] {
        [
            .today: DisplayRepresentation(
                title: "오늘",
                subtitle: "오늘 자정까지",
                image: .init(systemName: "sun.max.fill")
            ),
            .tomorrow: DisplayRepresentation(
                title: "내일",
                subtitle: "내일 자정까지",
                image: .init(systemName: "sunrise.fill")
            ),
            .thisWeekend: DisplayRepresentation(
                title: "이번 주말",
                subtitle: "이번 주 토요일까지",
                image: .init(systemName: "calendar.badge.clock")
            ),
            .nextWeek: DisplayRepresentation(
                title: "다음 주",
                subtitle: "일주일 후까지",
                image: .init(systemName: "calendar")
            ),
            .nextMonth: DisplayRepresentation(
                title: "다음 달",
                subtitle: "한 달 후까지",
                image: .init(systemName: "calendar.badge.plus")
            ),
            .none: DisplayRepresentation(
                title: "없음",
                subtitle: "마감일 없음",
                image: .init(systemName: "calendar.badge.minus")
            )
        ]
    }
    
    // MARK: - 실제 Date로 변환
    
    /// 프리셋을 실제 Date로 변환
    var date: Date? {
        switch self {
        case .today:
            return DueDate.today.date
        case .tomorrow:
            return DueDate.tomorrow.date
        case .thisWeekend:
            return DueDate.thisWeekend.date
        case .nextWeek:
            return DueDate.nextWeek.date
        case .nextMonth:
            return DueDate.nextMonth.date
        case .none:
            return nil
        }
    }
}

// MARK: - Date 확장
extension Date {
    
    /// DueDate로 변환
    var asDueDate: DueDate {
        DueDate(self)
    }
    
    /// 자연어로 마감일 파싱
    /// - Parameter string: "오늘", "내일", "다음주" 등의 문자열
    /// - Returns: 파싱된 날짜 (실패 시 nil)
    static func parseNaturalLanguage(_ string: String) -> Date? {
        let normalized = string.lowercased().trimmingCharacters(in: .whitespaces)
        
        switch normalized {
        case "오늘", "today":
            return DueDate.today.date
        case "내일", "tomorrow":
            return DueDate.tomorrow.date
        case "모레", "day after tomorrow":
            return Calendar.current.date(byAdding: .day, value: 2, to: Date())
        case "이번주", "this week":
            return DueDate.thisWeekend.date
        case "다음주", "next week":
            return DueDate.nextWeek.date
        case "다음달", "next month":
            return DueDate.nextMonth.date
        default:
            // 날짜 형식 파싱 시도
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            
            // 다양한 형식 시도
            let formats = [
                "yyyy-MM-dd",
                "MM/dd",
                "M월 d일",
                "M월d일"
            ]
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: normalized) {
                    return date
                }
            }
            
            return nil
        }
    }
}
