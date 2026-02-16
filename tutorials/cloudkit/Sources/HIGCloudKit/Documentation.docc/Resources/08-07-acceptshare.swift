import UIKit
import CloudKit

// SceneDelegate 또는 AppDelegate에서 공유 URL 처리

extension SceneDelegate {
    
    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        // 공유 수락 처리
        Task {
            do {
                try await CloudKitManager.shared.acceptShare(metadata: cloudKitShareMetadata)
                print("✅ Share accepted")
            } catch {
                print("❌ Failed to accept share: \(error)")
            }
        }
    }
}

// SwiftUI App에서는 .onOpenURL modifier 대신 
// UIApplicationDelegateAdaptor를 사용하여 처리
