import UserNotifications

extension NotificationManager {
    /// 지정된 시간(초) 후에 알림을 예약합니다
    func scheduleNotification(
        title: String,
        body: String,
        timeInterval: TimeInterval,
        identifier: String = UUID().uuidString
    ) async throws {
        // 1. 콘텐츠 구성
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // 2. 트리거 생성
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        
        // 3. 요청 생성 및 등록
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
}
