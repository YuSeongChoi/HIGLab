import UserNotifications

extension NotificationManager {
    /// 예약된 알림 목록을 조회합니다
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
    
    /// 특정 ID의 알림이 예약되어 있는지 확인합니다
    func isNotificationPending(identifier: String) async -> Bool {
        let pending = await getPendingNotifications()
        return pending.contains { $0.identifier == identifier }
    }
}

// 사용 예시
// Task {
//     let pending = await NotificationManager.shared.getPendingNotifications()
//     for request in pending {
//         print("ID: \(request.identifier)")
//         print("제목: \(request.content.title)")
//     }
// }
