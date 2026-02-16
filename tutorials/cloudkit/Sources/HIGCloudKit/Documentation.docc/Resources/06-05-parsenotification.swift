import CloudKit

extension CloudKitManager {
    
    /// CloudKit 알림 처리
    func handleNotification(_ notification: CKNotification) async throws {
        
        switch notification.notificationType {
        case .query:
            // Query 구독 알림
            if let queryNotification = notification as? CKQueryNotification {
                try await handleQueryNotification(queryNotification)
            }
            
        case .recordZone:
            // Zone 구독 알림
            if let zoneNotification = notification as? CKRecordZoneNotification {
                try await handleZoneNotification(zoneNotification)
            }
            
        case .database:
            // Database 구독 알림
            if let dbNotification = notification as? CKDatabaseNotification {
                try await handleDatabaseNotification(dbNotification)
            }
            
        case .readNotification:
            // 읽음 처리 알림
            break
            
        @unknown default:
            break
        }
    }
}
