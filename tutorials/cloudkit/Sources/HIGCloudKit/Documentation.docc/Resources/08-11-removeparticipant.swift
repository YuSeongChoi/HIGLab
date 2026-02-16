import CloudKit

extension CloudKitManager {
    
    /// 참여자 제거
    func removeParticipant(_ participant: CKShare.Participant, from share: CKShare) async throws {
        share.removeParticipant(participant)
        try await privateDatabase.save(share)
        print("✅ Participant removed")
    }
    
    /// 공유 완전히 중단
    func stopSharing(_ share: CKShare) async throws {
        // 공유 레코드 삭제
        try await privateDatabase.deleteRecord(withID: share.recordID)
        print("✅ Sharing stopped")
    }
    
    /// 공유에서 나가기 (참여자 입장)
    func leaveShare(in zoneID: CKRecordZone.ID) async throws {
        // Zone 삭제로 공유에서 나감
        let operation = CKModifyRecordZonesOperation(
            recordZonesToSave: nil,
            recordZoneIDsToDelete: [zoneID]
        )
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            operation.modifyRecordZonesResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            sharedDatabase.add(operation)
        }
    }
}
