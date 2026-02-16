import UserNotifications

extension NotificationManager {
    /// Date를 DateComponents로 변환합니다
    func dateComponents(from date: Date) -> DateComponents {
        Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
    }
    
    /// 특정 시간에 알림을 예약합니다
    func scheduleNotification(
        title: String,
        body: String,
        at date: Date,
        identifier: String = UUID().uuidString
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = dateComponents(from: date)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
}
