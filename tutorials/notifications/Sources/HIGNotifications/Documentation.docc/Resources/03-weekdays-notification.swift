import UserNotifications

extension NotificationManager {
    /// 평일에만 알림을 설정합니다 (월~금)
    func scheduleWeekdayNotification(
        title: String,
        body: String,
        hour: Int,
        minute: Int,
        baseIdentifier: String
    ) async throws {
        // 월요일(2)부터 금요일(6)까지 각각 알림 생성
        let weekdays = [2, 3, 4, 5, 6]
        
        for weekday in weekdays {
            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let identifier = "\(baseIdentifier)-weekday-\(weekday)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            try await center.add(request)
        }
    }
}
