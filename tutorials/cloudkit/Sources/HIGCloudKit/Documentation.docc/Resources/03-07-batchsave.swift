import CloudKit

extension CloudKitManager {
    
    /// 여러 레코드 배치 저장
    func saveNotes(_ notes: [Note]) async throws -> [Note] {
        let records = notes.map { $0.toRecord(in: notesZoneID) }
        
        // CKModifyRecordsOperation 사용
        let operation = CKModifyRecordsOperation(
            recordsToSave: records,
            recordIDsToDelete: nil
        )
        
        // 저장 정책 설정
        operation.savePolicy = .ifServerRecordUnchanged
        
        return try await withCheckedThrowingContinuation { continuation in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    let updatedNotes = zip(notes, records).map { note, record in
                        var updated = note
                        updated.recordID = record.recordID
                        return updated
                    }
                    continuation.resume(returning: updatedNotes)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            privateDatabase.add(operation)
        }
    }
}
