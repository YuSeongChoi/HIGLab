import CloudKit

extension CloudKitManager {
    
    /// 공유 권한 확인
    func checkPermission(for share: CKShare) -> CKShare.ParticipantPermission {
        // 현재 사용자 찾기
        guard let currentUser = share.currentUserParticipant else {
            return .none
        }
        
        return currentUser.permission
    }
    
    /// 쓰기 가능 여부
    func canWrite(to share: CKShare) -> Bool {
        let permission = checkPermission(for: share)
        return permission == .readWrite
    }
}
