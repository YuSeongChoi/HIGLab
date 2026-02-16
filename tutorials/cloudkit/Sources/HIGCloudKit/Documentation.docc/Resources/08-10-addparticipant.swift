import CloudKit

extension CloudKitManager {
    
    /// 이메일로 참여자 추가
    func addParticipant(
        email: String,
        to share: CKShare,
        permission: CKShare.ParticipantPermission
    ) async throws {
        // 사용자 검색
        let lookupInfo = CKUserIdentity.LookupInfo(emailAddress: email)
        
        let operation = CKFetchShareParticipantsOperation(
            userIdentityLookupInfos: [lookupInfo]
        )
        
        var participant: CKShare.Participant?
        
        operation.perShareParticipantResultBlock = { _, _, result in
            if case .success(let p) = result {
                participant = p
            }
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            operation.fetchShareParticipantsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            container.add(operation)
        }
        
        // 참여자 권한 설정 및 추가
        if let participant = participant {
            participant.permission = permission
            share.addParticipant(participant)
            
            // 공유 저장
            try await privateDatabase.save(share)
        }
    }
}
