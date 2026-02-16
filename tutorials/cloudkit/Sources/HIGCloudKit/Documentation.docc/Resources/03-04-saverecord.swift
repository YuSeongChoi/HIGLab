import CloudKit

extension CloudKitManager {
    
    /// 단일 레코드 저장
    func save(_ record: CKRecord) async throws -> CKRecord {
        try await privateDatabase.save(record)
    }
}
