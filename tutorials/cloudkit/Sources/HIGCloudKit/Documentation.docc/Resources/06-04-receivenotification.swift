import UIKit
import CloudKit

extension AppDelegate {
    
    // 원격 알림 수신
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // CloudKit 알림인지 확인
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            completionHandler(.noData)
            return
        }
        
        // 알림 처리
        Task {
            do {
                try await CloudKitManager.shared.handleNotification(notification)
                completionHandler(.newData)
            } catch {
                print("Error handling notification: \(error)")
                completionHandler(.failed)
            }
        }
    }
}
