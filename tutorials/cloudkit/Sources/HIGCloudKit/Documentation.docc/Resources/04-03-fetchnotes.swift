import CloudKit

extension CloudKitManager {
    
    /// 모든 메모를 Note 모델로 조회
    func fetchNotes() async throws -> [Note] {
        let records = try await fetchAllNotes()
        
        return records.compactMap { Note(from: $0) }
    }
}
