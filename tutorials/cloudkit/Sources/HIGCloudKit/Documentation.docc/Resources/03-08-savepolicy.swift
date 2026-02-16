import CloudKit

// CKModifyRecordsOperation.SavePolicy 옵션

// .ifServerRecordUnchanged (기본값)
// - 서버 레코드가 변경되지 않았을 때만 저장
// - 충돌 시 CKError.serverRecordChanged 에러 발생
// - 낙관적 잠금(Optimistic Locking) 방식

// .changedKeys
// - 변경된 필드만 업데이트
// - 다른 필드는 서버 값 유지
// - 필드별 병합에 유용

// .allKeys
// - 모든 필드를 클라이언트 값으로 덮어씀
// - 서버 변경 무시 (주의 필요!)
// - 복구, 강제 동기화에 사용

extension CloudKitManager {
    
    func saveWithPolicy(_ record: CKRecord, policy: CKModifyRecordsOperation.RecordSavePolicy) async throws {
        let operation = CKModifyRecordsOperation(recordsToSave: [record])
        operation.savePolicy = policy
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            privateDatabase.add(operation)
        }
    }
}
