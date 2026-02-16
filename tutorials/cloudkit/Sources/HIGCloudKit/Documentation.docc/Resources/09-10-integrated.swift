import CloudKit

extension CloudKitManager {
    
    /// 통합된 메모 저장 (모든 에러 처리 포함)
    func saveNoteRobustly(_ note: Note) async throws -> Note {
        var record = note.toRecord(in: notesZoneID)
        let resolver = ConflictResolver()
        
        var retryCount = 0
        let maxRetries = 3
        var delaySeconds: Double = 1.0
        
        while retryCount < maxRetries {
            do {
                let savedRecord = try await privateDatabase.save(record)
                return Note(from: savedRecord) ?? note
                
            } catch let error as CKError {
                retryCount += 1
                
                switch error.code {
                case .serverRecordChanged:
                    // 충돌 해결
                    if let conflict = extractConflictInfo(from: error, clientRecord: record) {
                        record = resolver.resolveWithFieldMerge(conflict: conflict)
                        continue
                    }
                    
                case .networkFailure, .networkUnavailable, .serviceUnavailable:
                    // 네트워크 에러 - 재시도
                    try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                    delaySeconds *= 2
                    continue
                    
                case .notAuthenticated:
                    throw CloudKitError.notSignedIn
                    
                case .quotaExceeded:
                    throw CloudKitError.quotaExceeded
                    
                default:
                    throw CloudKitError.unknown(error)
                }
            }
        }
        
        throw CloudKitError.maxRetriesExceeded
    }
}
