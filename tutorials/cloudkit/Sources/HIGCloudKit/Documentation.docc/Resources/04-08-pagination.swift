import CloudKit

extension CloudKitManager {
    
    /// 페이지 크기
    static let pageSize = 20
    
    /// 페이징 쿼리 결과
    struct PagedResult {
        let notes: [Note]
        let cursor: CKQueryOperation.Cursor?
        var hasMore: Bool { cursor != nil }
    }
    
    /// 첫 페이지 조회
    func fetchNotesPage() async throws -> PagedResult {
        let query = CKQuery(
            recordType: NoteRecord.recordType,
            predicate: NSPredicate(value: true)
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: NoteRecord.Field.modifiedAt, ascending: false)
        ]
        
        let (results, cursor) = try await privateDatabase.records(
            matching: query,
            inZoneWith: notesZoneID,
            desiredKeys: nil,
            resultsLimit: Self.pageSize
        )
        
        let notes = results.compactMap { _, result -> Note? in
            guard let record = try? result.get() else { return nil }
            return Note(from: record)
        }
        
        return PagedResult(notes: notes, cursor: cursor)
    }
}
