import CloudKit

extension CloudKitManager {
    
    /// Query 알림 처리
    func handleQueryNotification(_ notification: CKQueryNotification) async throws {
        guard let recordID = notification.recordID else { return }
        
        switch notification.queryNotificationReason {
        case .recordCreated:
            print("📝 Record created: \(recordID.recordName)")
            // 새 레코드 페치
            let record = try await privateDatabase.record(for: recordID)
            if let note = Note(from: record) {
                await MainActor.run {
                    // UI 업데이트 (예: @Published 배열에 추가)
                    NotificationCenter.default.post(
                        name: .noteCreated,
                        object: note
                    )
                }
            }
            
        case .recordUpdated:
            print("✏️ Record updated: \(recordID.recordName)")
            let record = try await privateDatabase.record(for: recordID)
            if let note = Note(from: record) {
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .noteUpdated,
                        object: note
                    )
                }
            }
            
        case .recordDeleted:
            print("🗑️ Record deleted: \(recordID.recordName)")
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .noteDeleted,
                    object: recordID
                )
            }
            
        @unknown default:
            break
        }
    }
}

// 알림 이름 정의
extension Notification.Name {
    static let noteCreated = Notification.Name("noteCreated")
    static let noteUpdated = Notification.Name("noteUpdated")
    static let noteDeleted = Notification.Name("noteDeleted")
}
