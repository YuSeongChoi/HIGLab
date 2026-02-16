import UIKit

extension AppDelegate {
    
    // 디바이스 토큰 수신 성공
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // CloudKit은 자동으로 토큰을 관리하므로 별도 처리 불필요
        // 디버깅용 로그
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ APNs token: \(tokenString.prefix(20))...")
    }
    
    // 등록 실패
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for notifications: \(error)")
    }
}
