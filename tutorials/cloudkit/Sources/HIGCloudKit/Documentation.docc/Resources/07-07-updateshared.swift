import CloudKit

extension CloudKitManager {
    
    /// 공유받은 메모 수정 (권한 확인 포함)
    func updateSharedNote(_ note: Note, in zoneID: CKRecordZone.ID) async throws -> Note {
        // 1. CKShare 조회
        let shareID = CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: zoneID)
        let shareRecord = try await sharedDatabase.record(for: shareID)
        
        guard let share = shareRecord as? CKShare else {
            throw CloudKitError.unknown(NSError(domain: "CloudKit", code: -1))
        }
        
        // 2. 쓰기 권한 확인
        guard canWrite(to: share) else {
            throw CloudKitError.permissionDenied
        }
        
        // 3. 레코드 수정
        guard let recordID = note.recordID else {
            throw CloudKitError.unknown(NSError(domain: "CloudKit", code: -1))
        }
        
        let record = try await sharedDatabase.record(for: recordID)
        record[NoteRecord.Field.title] = note.title
        record[NoteRecord.Field.content] = note.content
        record[NoteRecord.Field.modifiedAt] = Date()
        
        // 4. Shared Database에 저장
        let savedRecord = try await sharedDatabase.save(record)
        
        return Note(from: savedRecord) ?? note
    }
}

extension CloudKitError {
    static let permissionDenied = CloudKitError.unknown(
        NSError(domain: "CloudKit", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "쓰기 권한이 없습니다"
        ])
    )
}
