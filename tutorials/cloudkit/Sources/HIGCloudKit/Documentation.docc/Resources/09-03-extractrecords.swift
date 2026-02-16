import CloudKit

/// 충돌 정보
struct ConflictInfo {
    let ancestorRecord: CKRecord?  // 마지막 동기화 버전
    let clientRecord: CKRecord     // 로컬 버전
    let serverRecord: CKRecord     // 서버 최신 버전
}

extension CloudKitManager {
    
    /// CKError에서 충돌 정보 추출
    func extractConflictInfo(from error: CKError, clientRecord: CKRecord) -> ConflictInfo? {
        guard error.code == .serverRecordChanged else { return nil }
        
        // userInfo에서 레코드 추출
        let serverRecord = error.serverRecord
        let ancestorRecord = error.ancestorRecord
        
        guard let serverRecord = serverRecord else { return nil }
        
        return ConflictInfo(
            ancestorRecord: ancestorRecord,
            clientRecord: clientRecord,
            serverRecord: serverRecord
        )
    }
}

// CKError 확장
extension CKError {
    var serverRecord: CKRecord? {
        userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord
    }
    
    var ancestorRecord: CKRecord? {
        userInfo[CKRecordChangedErrorAncestorRecordKey] as? CKRecord
    }
    
    var clientRecord: CKRecord? {
        userInfo[CKRecordChangedErrorClientRecordKey] as? CKRecord
    }
}
