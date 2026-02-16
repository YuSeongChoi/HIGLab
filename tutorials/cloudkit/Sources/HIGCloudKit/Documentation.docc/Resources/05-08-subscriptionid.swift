import CloudKit

/// 구독 ID 관리
enum SubscriptionID {
    static let privateZone = "private-zone-subscription"
    static let sharedDatabase = "shared-database-subscription"
    static let noteQuery = "note-query-subscription"
    
    /// 디바이스별 고유 ID 생성 (중복 방지)
    static func deviceSpecific(_ base: String) -> String {
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        return "\(base)-\(deviceID.prefix(8))"
    }
}

extension CloudKitManager {
    
    /// 구독 존재 여부 확인 후 생성
    func ensureSubscription(id: String, create: () -> CKSubscription) async throws {
        let existing = try await privateDatabase.allSubscriptions()
        
        if existing.contains(where: { $0.subscriptionID == id }) {
            print("✅ Subscription already exists: \(id)")
            return
        }
        
        let subscription = create()
        try await privateDatabase.save(subscription)
        print("✅ Subscription created: \(id)")
    }
}
