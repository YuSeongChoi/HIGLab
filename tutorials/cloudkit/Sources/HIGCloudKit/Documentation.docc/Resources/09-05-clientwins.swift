import CloudKit

extension ConflictResolver {
    
    /// 클라이언트 우선 전략
    func resolveWithClientWins(conflict: ConflictInfo) -> CKRecord {
        // 서버 레코드의 changeTag로 업데이트
        let resolved = conflict.serverRecord
        
        // 클라이언트 값으로 덮어씀
        for key in conflict.clientRecord.allKeys() {
            resolved[key] = conflict.clientRecord[key]
        }
        
        return resolved
    }
}
