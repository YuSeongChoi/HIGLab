import CloudKit

extension CloudKitManager {
    
    /// 공유 수락 후 데이터 동기화
    func syncAfterAcceptingShare(metadata: CKShare.Metadata) async throws -> [Note] {
        // 1. 공유 수락
        try await acceptShare(metadata: metadata)
        
        // 2. 새로 공유받은 Zone 찾기
        let sharedZones = try await fetchSharedZones()
        
        // metadata에서 Zone 정보 추출
        let newZoneID = metadata.share.recordID.zoneID
        
        guard sharedZones.contains(where: { $0.zoneID == newZoneID }) else {
            return []
        }
        
        // 3. 해당 Zone의 메모 조회
        let notes = try await fetchSharedNotes(in: newZoneID)
        
        print("✅ Synced \(notes.count) shared notes")
        return notes
    }
}
