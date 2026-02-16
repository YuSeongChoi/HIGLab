import Foundation

// MARK: - 알림 데이터 모델

/// 예약된 로컬 알림을 나타내는 모델
struct NotificationItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var scheduledDate: Date
    var repeatInterval: RepeatInterval
    var category: NotificationCategory
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        body: String = "",
        scheduledDate: Date,
        repeatInterval: RepeatInterval = .none,
        category: NotificationCategory = .reminder,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.scheduledDate = scheduledDate
        self.repeatInterval = repeatInterval
        self.category = category
        self.isEnabled = isEnabled
    }
}

// MARK: - 반복 주기

enum RepeatInterval: String, CaseIterable, Codable {
    case none = "반복 안 함"
    case daily = "매일"
    case weekly = "매주"
    case monthly = "매월"
    
    /// 캘린더 컴포넌트로 변환
    var calendarComponents: Set<Calendar.Component>? {
        switch self {
        case .none: nil
        case .daily: [.hour, .minute]
        case .weekly: [.weekday, .hour, .minute]
        case .monthly: [.day, .hour, .minute]
        }
    }
    
    var symbol: String {
        switch self {
        case .none: "arrow.forward"
        case .daily: "sun.max"
        case .weekly: "calendar"
        case .monthly: "calendar.badge.clock"
        }
    }
}

// MARK: - Preview / Mock Data

extension NotificationItem {
    static let preview = NotificationItem(
        title: "물 마시기",
        body: "건강을 위해 물 한 잔 마셔요 💧",
        scheduledDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
        repeatInterval: .daily,
        category: .health
    )
    
    static let previewList: [NotificationItem] = [
        NotificationItem(
            title: "아침 스트레칭",
            body: "5분 스트레칭으로 하루를 시작하세요",
            scheduledDate: Calendar.current.date(
                bySettingHour: 7, minute: 30, second: 0, of: Date()
            )!,
            repeatInterval: .daily,
            category: .health
        ),
        NotificationItem(
            title: "팀 미팅",
            body: "주간 회의 - Zoom 링크 확인",
            scheduledDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            repeatInterval: .weekly,
            category: .work
        ),
        NotificationItem(
            title: "생일 축하 메시지 보내기",
            body: "엄마 생신 🎂",
            scheduledDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            repeatInterval: .none,
            category: .reminder
        ),
        NotificationItem(
            title: "약 복용",
            body: "비타민 챙기기",
            scheduledDate: Calendar.current.date(
                bySettingHour: 9, minute: 0, second: 0, of: Date()
            )!,
            repeatInterval: .daily,
            category: .health,
            isEnabled: false
        ),
    ]
}
