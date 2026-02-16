import CloudKit

extension CloudKitManager {
    
    /// 모든 메모 조회 (기본 쿼리)
    func fetchAllNotes() async throws -> [CKRecord] {
        // TRUEPREDICATE = 모든 레코드 조회
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(
            recordType: NoteRecord.recordType,
            predicate: predicate
        )
        
        // 수정일 기준 내림차순 정렬
        query.sortDescriptors = [
            NSSortDescriptor(key: NoteRecord.Field.modifiedAt, ascending: false)
        ]
        
        // 쿼리 실행
        let (records, _) = try await privateDatabase.records(
            matching: query,
            inZoneWith: notesZoneID
        )
        
        return records.compactMap { _, result in
            try? result.get()
        }
    }
}
