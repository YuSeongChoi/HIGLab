import CloudKit

extension CloudKitManager {
    
    /// Database 구독 생성 (Shared Database용)
    func createDatabaseSubscription() -> CKDatabaseSubscription {
        let subscription = CKDatabaseSubscription(
            subscriptionID: "shared-database-subscription"
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        
        return subscription
    }
    
    /// Shared Database 구독 설정
    func setupSharedDatabaseSubscription() async throws {
        let subscription = createDatabaseSubscription()
        
        // Shared Database에 저장
        try await sharedDatabase.save(subscription)
        print("✅ Shared database subscription saved")
    }
}
