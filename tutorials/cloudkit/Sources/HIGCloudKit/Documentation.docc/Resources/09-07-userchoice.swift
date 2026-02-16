import CloudKit
import SwiftUI

/// 사용자 선택 UI 모델
@MainActor
class ConflictResolutionViewModel: ObservableObject {
    @Published var showConflictAlert = false
    @Published var conflictInfo: ConflictInfo?
    
    private var continuation: CheckedContinuation<CKRecord, Error>?
    
    /// 사용자에게 선택 요청
    func askUserToResolve(conflict: ConflictInfo) async throws -> CKRecord {
        self.conflictInfo = conflict
        self.showConflictAlert = true
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    /// 사용자가 선택
    func userSelected(keepServerVersion: Bool) {
        guard let conflict = conflictInfo else { return }
        
        let resolved = keepServerVersion ? conflict.serverRecord : {
            let r = conflict.serverRecord
            for key in conflict.clientRecord.allKeys() {
                r[key] = conflict.clientRecord[key]
            }
            return r
        }()
        
        continuation?.resume(returning: resolved)
        continuation = nil
        showConflictAlert = false
        conflictInfo = nil
    }
}
