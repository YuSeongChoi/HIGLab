import CloudKit

extension CloudKitManager {
    
    /// 공유 참여자 정보
    struct ParticipantInfo {
        let name: String?
        let email: String?
        let role: CKShare.ParticipantRole
        let permission: CKShare.ParticipantPermission
        let acceptanceStatus: CKShare.ParticipantAcceptanceStatus
    }
    
    /// 공유 참여자 목록 조회
    func fetchParticipants(from share: CKShare) -> [ParticipantInfo] {
        share.participants.map { participant in
            ParticipantInfo(
                name: participant.userIdentity.nameComponents?.formatted(),
                email: participant.userIdentity.lookupInfo?.emailAddress,
                role: participant.role,
                permission: participant.permission,
                acceptanceStatus: participant.acceptanceStatus
            )
        }
    }
    
    /// 소유자 정보
    func fetchOwner(from share: CKShare) -> ParticipantInfo? {
        guard let owner = share.owner else { return nil }
        
        return ParticipantInfo(
            name: owner.userIdentity.nameComponents?.formatted(),
            email: owner.userIdentity.lookupInfo?.emailAddress,
            role: owner.role,
            permission: owner.permission,
            acceptanceStatus: owner.acceptanceStatus
        )
    }
}
