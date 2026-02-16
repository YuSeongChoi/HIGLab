import CloudKit

extension CloudKitManager {
    
    /// 정렬 옵션
    enum SortOption {
        case modifiedAtDesc  // 최신 수정순
        case modifiedAtAsc   // 오래된 수정순
        case titleAsc        // 제목 오름차순
        case titleDesc       // 제목 내림차순
        case createdAtDesc   // 최신 생성순
        
        var sortDescriptor: NSSortDescriptor {
            switch self {
            case .modifiedAtDesc:
                return NSSortDescriptor(key: NoteRecord.Field.modifiedAt, ascending: false)
            case .modifiedAtAsc:
                return NSSortDescriptor(key: NoteRecord.Field.modifiedAt, ascending: true)
            case .titleAsc:
                return NSSortDescriptor(key: NoteRecord.Field.title, ascending: true)
            case .titleDesc:
                return NSSortDescriptor(key: NoteRecord.Field.title, ascending: false)
            case .createdAtDesc:
                return NSSortDescriptor(key: NoteRecord.Field.createdAt, ascending: false)
            }
        }
    }
    
    /// 정렬된 메모 조회
    func fetchNotes(sortedBy sortOption: SortOption) async throws -> [Note] {
        let query = CKQuery(
            recordType: NoteRecord.recordType,
            predicate: NSPredicate(value: true)
        )
        query.sortDescriptors = [sortOption.sortDescriptor]
        
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
