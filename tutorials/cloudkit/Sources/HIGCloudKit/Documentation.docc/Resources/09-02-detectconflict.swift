import CloudKit

extension CloudKitManager {
    
    /// 충돌 감지 저장
    func saveWithConflictDetection(_ record: CKRecord) async throws -> CKRecord {
        do {
            return try await privateDatabase.save(record)
        } catch let error as CKError where error.code == .serverRecordChanged {
            // 충돌 발생!
            print("⚠️ Conflict detected for record: \(record.recordID)")
            throw error
        }
    }
}
