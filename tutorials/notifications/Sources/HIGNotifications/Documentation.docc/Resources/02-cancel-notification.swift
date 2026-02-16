import UserNotifications

extension NotificationManager {
    /// 특정 알림을 취소합니다
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }
    
    /// 여러 알림을 취소합니다
    func cancelNotifications(identifiers: [String]) {
        center.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }
    
    /// 전달된 알림도 제거합니다 (알림 센터에서)
    func removeDeliveredNotification(identifier: String) {
        center.removeDeliveredNotifications(
            withIdentifiers: [identifier]
        )
    }
}
