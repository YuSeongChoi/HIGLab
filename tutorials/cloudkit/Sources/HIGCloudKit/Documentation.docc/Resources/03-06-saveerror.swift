import CloudKit

extension CloudKitManager {
    
    /// 에러 처리를 포함한 메모 저장
    func saveNoteWithErrorHandling(_ note: Note) async throws -> Note {
        do {
            return try await saveNote(note)
        } catch let error as CKError {
            switch error.code {
            case .networkFailure, .networkUnavailable:
                throw CloudKitError.networkError
            case .notAuthenticated:
                throw CloudKitError.notSignedIn
            case .quotaExceeded:
                throw CloudKitError.quotaExceeded
            case .serverRecordChanged:
                throw CloudKitError.conflict(serverRecord: error.serverRecord)
            default:
                throw CloudKitError.unknown(error)
            }
        }
    }
}

/// CloudKit 에러 타입
enum CloudKitError: Error {
    case networkError
    case notSignedIn
    case quotaExceeded
    case conflict(serverRecord: CKRecord?)
    case unknown(Error)
}
