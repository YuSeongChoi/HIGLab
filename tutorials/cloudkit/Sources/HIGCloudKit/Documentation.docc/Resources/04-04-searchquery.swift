import CloudKit

extension CloudKitManager {
    
    /// 제목으로 메모 검색
    func searchNotes(title: String) async throws -> [Note] {
        // CONTAINS 연산자로 부분 일치 검색
        // BEGINSWITH: 접두사 검색
        // ==: 정확히 일치
        let predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            NoteRecord.Field.title,
            title
        )
        // [c] = 대소문자 무시, [d] = 발음 기호 무시
        
        let query = CKQuery(
            recordType: NoteRecord.recordType,
            predicate: predicate
        )
        
        let (records, _) = try await privateDatabase.records(
            matching: query,
            inZoneWith: notesZoneID
        )
        
        return records.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return Note(from: record)
        }
    }
}
