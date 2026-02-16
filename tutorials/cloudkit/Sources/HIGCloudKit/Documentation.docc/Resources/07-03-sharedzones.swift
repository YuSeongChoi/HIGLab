import CloudKit

extension CloudKitManager {
    
    /// 공유받은 모든 Zone 조회
    func fetchSharedZones() async throws -> [CKRecordZone] {
        try await sharedDatabase.allRecordZones()
    }
    
    /// 공유받은 Zone 정보와 함께 CKShare 조회
    func fetchSharedZonesWithMetadata() async throws -> [(zone: CKRecordZone, share: CKShare?)] {
        let zones = try await fetchSharedZones()
        
        var results: [(CKRecordZone, CKShare?)] = []
        
        for zone in zones {
            // 각 Zone의 CKShare 조회
            let shareID = CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: zone.zoneID)
            
            do {
                let shareRecord = try await sharedDatabase.record(for: shareID)
                let share = shareRecord as? CKShare
                results.append((zone, share))
            } catch {
                results.append((zone, nil))
            }
        }
        
        return results
    }
}
