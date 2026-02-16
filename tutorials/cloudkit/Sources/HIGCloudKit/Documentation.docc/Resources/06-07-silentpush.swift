import CloudKit

extension CloudKitManager {
    
    /// Silent Push용 구독 생성
    func createSilentSubscription() -> CKRecordZoneSubscription {
        let subscription = CKRecordZoneSubscription(
            zoneID: notesZoneID,
            subscriptionID: "notes-silent-subscription"
        )
        
        // Silent Push 설정
        let notificationInfo = CKSubscription.NotificationInfo()
        
        // 핵심: 백그라운드 페치 활성화
        notificationInfo.shouldSendContentAvailable = true
        
        // 사용자에게 표시 안 함
        notificationInfo.alertBody = nil
        notificationInfo.soundName = nil
        notificationInfo.shouldBadge = false
        
        subscription.notificationInfo = notificationInfo
        
        return subscription
    }
}
