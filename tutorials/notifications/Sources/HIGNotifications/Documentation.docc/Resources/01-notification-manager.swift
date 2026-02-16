import UserNotifications
import Observation

@Observable
final class NotificationManager {
    static let shared = NotificationManager()
    
    // 권한 상태
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // 현재 권한 상태 확인
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
}
