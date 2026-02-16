import UserNotifications

enum RepeatOption: String, CaseIterable {
    case never = "반복 안 함"
    case daily = "매일"
    case weekdays = "평일"
    case weekly = "매주"
    case monthly = "매월"
    
    /// 이 옵션에 맞는 트리거들을 생성합니다
    func createTriggers(hour: Int, minute: Int, weekday: Int? = nil, day: Int? = nil) -> [UNCalendarNotificationTrigger] {
        switch self {
        case .never:
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return [UNCalendarNotificationTrigger(dateMatching: components, repeats: false)]
            
        case .daily:
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return [UNCalendarNotificationTrigger(dateMatching: components, repeats: true)]
            
        case .weekdays:
            return (2...6).map { weekday in
                var components = DateComponents()
                components.weekday = weekday
                components.hour = hour
                components.minute = minute
                return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            }
            
        case .weekly:
            var components = DateComponents()
            components.weekday = weekday ?? 2
            components.hour = hour
            components.minute = minute
            return [UNCalendarNotificationTrigger(dateMatching: components, repeats: true)]
            
        case .monthly:
            var components = DateComponents()
            components.day = day ?? 1
            components.hour = hour
            components.minute = minute
            return [UNCalendarNotificationTrigger(dateMatching: components, repeats: true)]
        }
    }
}
