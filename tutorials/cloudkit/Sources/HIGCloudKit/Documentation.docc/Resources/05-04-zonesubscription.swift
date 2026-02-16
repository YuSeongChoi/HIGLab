import CloudKit

extension CloudKitManager {
    
    /// Zone 기반 구독 생성
    func createZoneSubscription() -> CKRecordZoneSubscription {
        let subscription = CKRecordZoneSubscription(
            zoneID: notesZoneID,
            subscriptionID: "notes-zone-subscription"
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        
        return subscription
    }
}
