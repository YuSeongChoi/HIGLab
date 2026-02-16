import UIKit
import CloudKit

extension AppDelegate {
    
    // 백그라운드 알림 처리
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            completionHandler(.noData)
            return
        }
        
        // 백그라운드 작업 시작 (시간 제한 있음)
        let taskID = application.beginBackgroundTask {
            // 시간 초과 시 호출
            completionHandler(.failed)
        }
        
        Task {
            do {
                // 변경된 데이터 동기화
                let hasChanges = try await CloudKitManager.shared.syncChanges()
                
                await MainActor.run {
                    application.endBackgroundTask(taskID)
                    completionHandler(hasChanges ? .newData : .noData)
                }
            } catch {
                await MainActor.run {
                    application.endBackgroundTask(taskID)
                    completionHandler(.failed)
                }
            }
        }
    }
}
