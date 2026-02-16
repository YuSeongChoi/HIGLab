import CloudKit

extension CloudKitManager {
    
    /// 특정 공유 Zone의 메모 조회
    func fetchSharedNotes(in zoneID: CKRecordZone.ID) async throws -> [Note] {
        let query = CKQuery(
            recordType: NoteRecord.recordType,
            predicate: NSPredicate(value: true)
        )
        
        let (results, _) = try await sharedDatabase.records(
            matching: query,
            inZoneWith: zoneID
        )
        
        return results.compactMap { _, result -> Note? in
            guard let record = try? result.get() else { return nil }
            var note = Note(from: record)
            note?.isShared = true
            return note
        }
    }
    
    /// 모든 공유받은 메모 조회
    func fetchAllSharedNotes() async throws -> [Note] {
        let zones = try await fetchSharedZones()
        var allNotes: [Note] = []
        
        for zone in zones {
            let notes = try await fetchSharedNotes(in: zone.zoneID)
            allNotes.append(contentsOf: notes)
        }
        
        return allNotes
    }
}
