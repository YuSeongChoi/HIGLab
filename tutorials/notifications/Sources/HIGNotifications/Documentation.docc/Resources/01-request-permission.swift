import UserNotifications

extension NotificationManager {
    /// 알림 권한을 요청합니다
    /// - Returns: 권한 허용 여부
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            // 권한 상태 업데이트
            await checkAuthorizationStatus()
            
            return granted
        } catch {
            print("권한 요청 실패: \(error.localizedDescription)")
            return false
        }
    }
}

// 사용 예시
// Task {
//     let granted = await NotificationManager.shared.requestAuthorization()
//     print("알림 권한: \(granted ? "허용" : "거부")")
// }
