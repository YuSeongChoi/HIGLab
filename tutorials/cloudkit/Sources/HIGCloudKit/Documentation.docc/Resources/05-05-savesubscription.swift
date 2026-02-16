import CloudKit

extension CloudKitManager {
    
    /// 구독을 서버에 저장
    func saveSubscription(_ subscription: CKSubscription) async throws {
        try await privateDatabase.save(subscription)
        print("✅ Subscription saved: \(subscription.subscriptionID)")
    }
    
    /// Zone 구독 설정 (앱 시작 시 한 번 호출)
    func setupSubscriptions() async throws {
        // 이미 구독이 있는지 확인
        let existingSubscriptions = try await privateDatabase.allSubscriptions()
        
        let zoneSubID = "notes-zone-subscription"
        let hasZoneSub = existingSubscriptions.contains { $0.subscriptionID == zoneSubID }
        
        if !hasZoneSub {
            let subscription = createZoneSubscription()
            try await saveSubscription(subscription)
        }
    }
}
