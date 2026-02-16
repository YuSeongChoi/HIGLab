import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // 원격 알림 등록
        registerForRemoteNotifications(application)
        
        return true
    }
    
    private func registerForRemoteNotifications(_ application: UIApplication) {
        // 알림 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    // APNs에 디바이스 등록
                    application.registerForRemoteNotifications()
                }
            }
            
            if let error = error {
                print("Notification auth error: \(error)")
            }
        }
    }
}
