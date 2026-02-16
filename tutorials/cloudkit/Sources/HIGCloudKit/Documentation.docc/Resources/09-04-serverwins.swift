import CloudKit

/// 충돌 해결 전략
enum ConflictResolutionStrategy {
    case serverWins      // 서버 우선
    case clientWins      // 클라이언트 우선
    case merge           // 필드별 병합
    case userChoice      // 사용자 선택
}

/// 충돌 해결기
class ConflictResolver {
    
    /// 서버 우선 전략 - 가장 간단
    func resolveWithServerWins(conflict: ConflictInfo) -> CKRecord {
        // 서버 레코드를 그대로 사용
        // 로컬 변경사항은 버려짐
        return conflict.serverRecord
    }
}
