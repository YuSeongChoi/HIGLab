import CloudKit
import Foundation

extension CloudKitManager {
    
    /// 복합 조건 쿼리
    func fetchNotes(
        titleContains: String?,
        since: Date?,
        sortByTitle: Bool = false
    ) async throws -> [Note] {
        
        var subpredicates: [NSPredicate] = []
        
        // 제목 검색 조건
        if let title = titleContains, !title.isEmpty {
            subpredicates.append(
                NSPredicate(format: "%K CONTAINS[cd] %@", NoteRecord.Field.title, title)
            )
        }
        
        // 날짜 조건
        if let since = since {
            subpredicates.append(
                NSPredicate(format: "%K >= %@", NoteRecord.Field.modifiedAt, since as NSDate)
            )
        }
        
        // AND 조건으로 결합 (subpredicates가 비어있으면 TRUEPREDICATE)
        let predicate: NSPredicate
        if subpredicates.isEmpty {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        }
        
        // OR 조건 예시:
        // NSCompoundPredicate(orPredicateWithSubpredicates: subpredicates)
        
        let query = CKQuery(recordType: NoteRecord.recordType, predicate: predicate)
        
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
