import UserNotifications

extension NotificationManager {
    /// 반복 옵션에 따라 알림을 예약합니다
    func scheduleRepeatingNotification(
        title: String,
        body: String,
        hour: Int,
        minute: Int,
        repeatOption: RepeatOption,
        baseIdentifier: String
    ) async throws {
        let triggers = repeatOption.createTriggers(hour: hour, minute: minute)
        
        for (index, trigger) in triggers.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let identifier = triggers.count > 1 
                ? "\(baseIdentifier)-\(index)"
                : baseIdentifier
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            try await center.add(request)
        }
    }
}
