import Foundation
import EventKit

// MARK: - 리마인더 모델
/// EventKit의 EKReminder를 래핑하여 SwiftUI에서 사용하기 쉽게 만든 모델
struct ReminderItem: Identifiable, Hashable {
    let id: String
    var title: String
    var notes: String?
    var isCompleted: Bool
    var completionDate: Date?
    var dueDate: Date?
    var priority: ReminderPriority
    var listIdentifier: String
    var listTitle: String
    var listColor: CGColor?
    var alarms: [ReminderAlarm]
    var recurrenceRule: RecurrenceRule?
    
    // MARK: - EKReminder로부터 초기화
    init(from ekReminder: EKReminder) {
        self.id = ekReminder.calendarItemIdentifier
        self.title = ekReminder.title ?? "제목 없음"
        self.notes = ekReminder.notes
        self.isCompleted = ekReminder.isCompleted
        self.completionDate = ekReminder.completionDate
        self.listIdentifier = ekReminder.calendar.calendarIdentifier
        self.listTitle = ekReminder.calendar.title
        self.listColor = ekReminder.calendar.cgColor
        self.priority = ReminderPriority(from: ekReminder.priority)
        
        // 기한일 처리
        if let dueDateComponents = ekReminder.dueDateComponents {
            self.dueDate = Calendar.current.date(from: dueDateComponents)
        } else {
            self.dueDate = nil
        }
        
        // 알림 변환
        self.alarms = ekReminder.alarms?.map { ReminderAlarm(from: $0) } ?? []
        
        // 반복 규칙 변환
        if let rule = ekReminder.recurrenceRules?.first {
            self.recurrenceRule = RecurrenceRule(from: rule)
        } else {
            self.recurrenceRule = nil
        }
    }
    
    // MARK: - 새 리마인더 생성용 초기화
    init(
        title: String = "",
        notes: String? = nil,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priority: ReminderPriority = .none,
        listIdentifier: String = "",
        alarms: [ReminderAlarm] = [],
        recurrenceRule: RecurrenceRule? = nil
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.completionDate = nil
        self.dueDate = dueDate
        self.priority = priority
        self.listIdentifier = listIdentifier
        self.listTitle = ""
        self.listColor = nil
        self.alarms = alarms
        self.recurrenceRule = recurrenceRule
    }
    
    // MARK: - Hashable 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ReminderItem, rhs: ReminderItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 리마인더 우선순위
enum ReminderPriority: Int, CaseIterable {
    case none = 0
    case low = 9
    case medium = 5
    case high = 1
    
    init(from ekPriority: Int) {
        switch ekPriority {
        case 1...4: self = .high
        case 5: self = .medium
        case 6...9: self = .low
        default: self = .none
        }
    }
    
    var displayText: String {
        switch self {
        case .none: return "없음"
        case .low: return "낮음"
        case .medium: return "보통"
        case .high: return "높음"
        }
    }
    
    var symbolName: String {
        switch self {
        case .none: return ""
        case .low: return "exclamationmark"
        case .medium: return "exclamationmark.2"
        case .high: return "exclamationmark.3"
        }
    }
}

// MARK: - 리마인더 알림 모델
struct ReminderAlarm: Identifiable, Hashable {
    let id = UUID()
    var absoluteDate: Date?
    var offsetMinutes: Int? // 기한 전 분 단위
    
    // 절대 시간 알림
    init(absoluteDate: Date) {
        self.absoluteDate = absoluteDate
        self.offsetMinutes = nil
    }
    
    // 상대 시간 알림
    init(offsetMinutes: Int) {
        self.absoluteDate = nil
        self.offsetMinutes = offsetMinutes
    }
    
    init(from ekAlarm: EKAlarm) {
        if let date = ekAlarm.absoluteDate {
            self.absoluteDate = date
            self.offsetMinutes = nil
        } else {
            self.absoluteDate = nil
            self.offsetMinutes = Int(abs(ekAlarm.relativeOffset) / 60)
        }
    }
    
    func toEKAlarm() -> EKAlarm {
        if let date = absoluteDate {
            return EKAlarm(absoluteDate: date)
        } else if let minutes = offsetMinutes {
            return EKAlarm(relativeOffset: TimeInterval(-minutes * 60))
        }
        return EKAlarm(relativeOffset: 0)
    }
    
    var displayText: String {
        if let date = absoluteDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        } else if let minutes = offsetMinutes {
            if minutes == 0 {
                return "기한 시"
            } else if minutes < 60 {
                return "\(minutes)분 전"
            } else if minutes < 1440 {
                return "\(minutes / 60)시간 전"
            } else {
                return "\(minutes / 1440)일 전"
            }
        }
        return "알림"
    }
}

// MARK: - 리마인더 목록 정보 모델
struct ReminderList: Identifiable, Hashable {
    let id: String
    let title: String
    let color: CGColor
    let isSubscribed: Bool
    let allowsModify: Bool
    var incompleteCount: Int
    
    init(from ekCalendar: EKCalendar, incompleteCount: Int = 0) {
        self.id = ekCalendar.calendarIdentifier
        self.title = ekCalendar.title
        self.color = ekCalendar.cgColor
        self.isSubscribed = ekCalendar.isSubscribed
        self.allowsModify = ekCalendar.allowsContentModifications
        self.incompleteCount = incompleteCount
    }
}

// MARK: - 리마인더 필터
enum ReminderFilter: String, CaseIterable {
    case all = "전체"
    case today = "오늘"
    case scheduled = "예정됨"
    case completed = "완료됨"
    case flagged = "중요"
    
    var symbolName: String {
        switch self {
        case .all: return "tray.full"
        case .today: return "calendar"
        case .scheduled: return "calendar.badge.clock"
        case .completed: return "checkmark.circle"
        case .flagged: return "flag"
        }
    }
}
