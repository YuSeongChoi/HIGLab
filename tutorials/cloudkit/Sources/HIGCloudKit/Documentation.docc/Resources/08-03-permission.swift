import CloudKit

extension CloudKitManager {
    
    /// 공유 권한 설정
    func configureShare(_ share: CKShare, publicPermission: CKShare.ParticipantPermission) {
        // URL을 통한 접근 권한
        share.publicPermission = publicPermission
    }
    
    /// 공유 저장 (레코드와 함께)
    func saveShare(_ share: CKShare, rootRecord: CKRecord) async throws -> CKShare {
        let operation = CKModifyRecordsOperation(
            recordsToSave: [share, rootRecord],
            recordIDsToDelete: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume(returning: share)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            privateDatabase.add(operation)
        }
    }
}
