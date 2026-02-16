import CloudKit

extension CloudKitManager {
    
    /// 모든 구독 조회
    func fetchAllSubscriptions() async throws -> [CKSubscription] {
        try await privateDatabase.allSubscriptions()
    }
    
    /// 구독 삭제
    func deleteSubscription(id: CKSubscription.ID) async throws {
        try await privateDatabase.deleteSubscription(withID: id)
        print("🗑️ Subscription deleted: \(id)")
    }
    
    /// 모든 구독 삭제 (테스트/디버그용)
    func deleteAllSubscriptions() async throws {
        let subscriptions = try await fetchAllSubscriptions()
        
        for subscription in subscriptions {
            try await deleteSubscription(id: subscription.subscriptionID)
        }
    }
}
