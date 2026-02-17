import Foundation
import EventKit

// MARK: - 캘린더 이벤트 모델
/// EventKit의 EKEvent를 래핑하여 SwiftUI에서 사용하기 쉽게 만든 모델
struct CalendarEvent: Identifiable, Hashable {
    let id: String
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var location: String?
    var notes: String?
    var calendarIdentifier: String
    var calendarTitle: String
    var calendarColor: CGColor?
    var recurrenceRule: RecurrenceRule?
    var alarms: [EventAlarm]
    
    // MARK: - EKEvent로부터 초기화
    init(from ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier ?? UUID().uuidString
        self.title = ekEvent.title ?? "제목 없음"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.isAllDay = ekEvent.isAllDay
        self.location = ekEvent.location
        self.notes = ekEvent.notes
        self.calendarIdentifier = ekEvent.calendar.calendarIdentifier
        self.calendarTitle = ekEvent.calendar.title
        self.calendarColor = ekEvent.calendar.cgColor
        
        // 반복 규칙 변환
        if let rule = ekEvent.recurrenceRules?.first {
            self.recurrenceRule = RecurrenceRule(from: rule)
        } else {
            self.recurrenceRule = nil
        }
        
        // 알림 변환
        self.alarms = ekEvent.alarms?.map { EventAlarm(from: $0) } ?? []
    }
    
    // MARK: - 새 이벤트 생성용 초기화
    init(
        title: String = "",
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(3600),
        isAllDay: Bool = false,
        location: String? = nil,
        notes: String? = nil,
        calendarIdentifier: String = "",
        recurrenceRule: RecurrenceRule? = nil,
        alarms: [EventAlarm] = []
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.notes = notes
        self.calendarIdentifier = calendarIdentifier
        self.calendarTitle = ""
        self.calendarColor = nil
        self.recurrenceRule = recurrenceRule
        self.alarms = alarms
    }
    
    // MARK: - Hashable 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 반복 규칙 모델
/// 이벤트 반복 설정을 위한 모델
struct RecurrenceRule: Hashable {
    var frequency: RecurrenceFrequency
    var interval: Int
    var endDate: Date?
    var occurrenceCount: Int?
    
    init(
        frequency: RecurrenceFrequency = .daily,
        interval: Int = 1,
        endDate: Date? = nil,
        occurrenceCount: Int? = nil
    ) {
        self.frequency = frequency
        self.interval = interval
        self.endDate = endDate
        self.occurrenceCount = occurrenceCount
    }
    
    // EKRecurrenceRule로부터 초기화
    init(from ekRule: EKRecurrenceRule) {
        self.frequency = RecurrenceFrequency(from: ekRule.frequency)
        self.interval = ekRule.interval
        
        if let end = ekRule.recurrenceEnd {
            self.endDate = end.endDate
            self.occurrenceCount = end.occurrenceCount > 0 ? end.occurrenceCount : nil
        } else {
            self.endDate = nil
            self.occurrenceCount = nil
        }
    }
    
    // EKRecurrenceRule로 변환
    func toEKRecurrenceRule() -> EKRecurrenceRule {
        var recurrenceEnd: EKRecurrenceEnd?
        
        if let endDate = endDate {
            recurrenceEnd = EKRecurrenceEnd(end: endDate)
        } else if let count = occurrenceCount {
            recurrenceEnd = EKRecurrenceEnd(occurrenceCount: count)
        }
        
        return EKRecurrenceRule(
            recurrenceWith: frequency.toEKFrequency(),
            interval: interval,
            end: recurrenceEnd
        )
    }
}

// MARK: - 반복 빈도
enum RecurrenceFrequency: String, CaseIterable, Hashable {
    case daily = "매일"
    case weekly = "매주"
    case monthly = "매월"
    case yearly = "매년"
    
    init(from ekFrequency: EKRecurrenceFrequency) {
        switch ekFrequency {
        case .daily: self = .daily
        case .weekly: self = .weekly
        case .monthly: self = .monthly
        case .yearly: self = .yearly
        @unknown default: self = .daily
        }
    }
    
    func toEKFrequency() -> EKRecurrenceFrequency {
        switch self {
        case .daily: return .daily
        case .weekly: return .weekly
        case .monthly: return .monthly
        case .yearly: return .yearly
        }
    }
}

// MARK: - 알림 모델
struct EventAlarm: Identifiable, Hashable {
    let id = UUID()
    var offsetMinutes: Int // 이벤트 시작 전 분 단위
    
    init(offsetMinutes: Int = 15) {
        self.offsetMinutes = offsetMinutes
    }
    
    init(from ekAlarm: EKAlarm) {
        // relativeOffset은 초 단위이며 음수(이벤트 전)
        self.offsetMinutes = Int(abs(ekAlarm.relativeOffset) / 60)
    }
    
    func toEKAlarm() -> EKAlarm {
        return EKAlarm(relativeOffset: TimeInterval(-offsetMinutes * 60))
    }
    
    // 표시용 문자열
    var displayText: String {
        if offsetMinutes == 0 {
            return "이벤트 시작 시"
        } else if offsetMinutes < 60 {
            return "\(offsetMinutes)분 전"
        } else if offsetMinutes < 1440 {
            let hours = offsetMinutes / 60
            return "\(hours)시간 전"
        } else {
            let days = offsetMinutes / 1440
            return "\(days)일 전"
        }
    }
}

// MARK: - 알림 프리셋
enum AlarmPreset: CaseIterable {
    case atTime
    case fiveMinutes
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case oneDay
    
    var offsetMinutes: Int {
        switch self {
        case .atTime: return 0
        case .fiveMinutes: return 5
        case .fifteenMinutes: return 15
        case .thirtyMinutes: return 30
        case .oneHour: return 60
        case .oneDay: return 1440
        }
    }
    
    var displayText: String {
        switch self {
        case .atTime: return "이벤트 시작 시"
        case .fiveMinutes: return "5분 전"
        case .fifteenMinutes: return "15분 전"
        case .thirtyMinutes: return "30분 전"
        case .oneHour: return "1시간 전"
        case .oneDay: return "1일 전"
        }
    }
}

// MARK: - 캘린더 정보 모델
struct CalendarInfo: Identifiable, Hashable {
    let id: String
    let title: String
    let color: CGColor
    let type: EKCalendarType
    let isSubscribed: Bool
    let allowsModify: Bool
    
    init(from ekCalendar: EKCalendar) {
        self.id = ekCalendar.calendarIdentifier
        self.title = ekCalendar.title
        self.color = ekCalendar.cgColor
        self.type = ekCalendar.type
        self.isSubscribed = ekCalendar.isSubscribed
        self.allowsModify = ekCalendar.allowsContentModifications
    }
    
    // 타입 표시 문자열
    var typeDisplayText: String {
        switch type {
        case .local: return "로컬"
        case .calDAV: return "CalDAV"
        case .exchange: return "Exchange"
        case .subscription: return "구독"
        case .birthday: return "생일"
        @unknown default: return "기타"
        }
    }
}
