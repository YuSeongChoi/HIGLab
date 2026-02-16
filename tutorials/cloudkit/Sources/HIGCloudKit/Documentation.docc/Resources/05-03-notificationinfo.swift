import CloudKit

extension CloudKitManager {
    
    /// 알림 정보 설정
    func createNotificationInfo(silent: Bool = false) -> CKSubscription.NotificationInfo {
        let notificationInfo = CKSubscription.NotificationInfo()
        
        if silent {
            // Silent Push (백그라운드 동기화용)
            notificationInfo.shouldSendContentAvailable = true
        } else {
            // 사용자에게 표시되는 알림
            notificationInfo.alertLocalizationKey = "NOTE_UPDATED"
            notificationInfo.titleLocalizationKey = "NOTE_UPDATED_TITLE"
            notificationInfo.soundName = "default"
            notificationInfo.shouldBadge = true
        }
        
        // 변경된 레코드 ID 포함
        notificationInfo.desiredKeys = [NoteRecord.Field.title]
        
        return notificationInfo
    }
}
