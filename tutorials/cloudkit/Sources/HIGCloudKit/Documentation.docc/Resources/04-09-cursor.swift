import CloudKit

extension CloudKitManager {
    
    /// 다음 페이지 조회 (cursor 사용)
    func fetchNotesPage(after cursor: CKQueryOperation.Cursor) async throws -> PagedResult {
        let (results, nextCursor) = try await privateDatabase.records(
            continuingMatchFrom: cursor,
            desiredKeys: nil,
            resultsLimit: Self.pageSize
        )
        
        let notes = results.compactMap { _, result -> Note? in
            guard let record = try? result.get() else { return nil }
            return Note(from: record)
        }
        
        return PagedResult(notes: notes, cursor: nextCursor)
    }
}
