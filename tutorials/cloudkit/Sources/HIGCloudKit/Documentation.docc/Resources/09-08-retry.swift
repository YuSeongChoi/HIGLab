import CloudKit

extension CloudKitManager {
    
    /// 자동 재시도 저장
    func saveWithRetry(
        _ record: CKRecord,
        maxRetries: Int = 3,
        strategy: ConflictResolutionStrategy = .merge
    ) async throws -> CKRecord {
        
        var currentRecord = record
        var retryCount = 0
        let resolver = ConflictResolver()
        
        while retryCount < maxRetries {
            do {
                return try await privateDatabase.save(currentRecord)
            } catch let error as CKError where error.code == .serverRecordChanged {
                retryCount += 1
                
                guard let conflictInfo = extractConflictInfo(from: error, clientRecord: currentRecord) else {
                    throw error
                }
                
                // 전략에 따라 해결
                switch strategy {
                case .serverWins:
                    currentRecord = resolver.resolveWithServerWins(conflict: conflictInfo)
                case .clientWins:
                    currentRecord = resolver.resolveWithClientWins(conflict: conflictInfo)
                case .merge:
                    currentRecord = resolver.resolveWithFieldMerge(conflict: conflictInfo)
                case .userChoice:
                    throw error // UI에서 처리
                }
                
                print("🔄 Retry \(retryCount)/\(maxRetries)")
            }
        }
        
        throw CloudKitError.maxRetriesExceeded
    }
}

extension CloudKitError {
    static let maxRetriesExceeded = CloudKitError.unknown(
        NSError(domain: "CloudKit", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "최대 재시도 횟수 초과"
        ])
    )
}
