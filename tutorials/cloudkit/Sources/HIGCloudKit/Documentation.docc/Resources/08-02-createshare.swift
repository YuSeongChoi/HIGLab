import CloudKit

extension CloudKitManager {
    
    /// 메모에 대한 CKShare 생성
    func createShare(for note: Note) async throws -> CKShare {
        guard let recordID = note.recordID else {
            throw CloudKitError.unknown(NSError(domain: "CloudKit", code: -1))
        }
        
        // 레코드 조회
        let record = try await privateDatabase.record(for: recordID)
        
        // CKShare 생성
        let share = CKShare(rootRecord: record)
        
        // 기본 설정
        share[CKShare.SystemFieldKey.title] = note.title
        share[CKShare.SystemFieldKey.shareType] = "com.example.note"
        
        return share
    }
    
    /// Zone 전체 공유
    func createZoneShare() async throws -> CKShare {
        let share = CKShare(recordZoneID: notesZoneID)
        
        share[CKShare.SystemFieldKey.title] = "내 메모장"
        
        return share
    }
}
