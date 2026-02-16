import UserNotifications

extension NotificationManager {
    /// 모든 예약된 알림을 취소합니다
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// 모든 전달된 알림을 제거합니다 (알림 센터에서)
    func removeAllDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
    }
    
    /// 예약 + 전달된 모든 알림을 정리합니다
    func clearAllNotifications() {
        cancelAllNotifications()
        removeAllDeliveredNotifications()
    }
}

// 사용 예시: 로그아웃 시
// func logout() {
//     NotificationManager.shared.clearAllNotifications()
//     // 다른 정리 작업...
// }
