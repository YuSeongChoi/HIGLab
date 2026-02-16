import CloudKit
import Foundation

extension CloudKitManager {
    
    /// 지수 백오프 재시도
    func saveWithExponentialBackoff(
        _ record: CKRecord,
        maxRetries: Int = 5
    ) async throws -> CKRecord {
        
        var retryCount = 0
        var delaySeconds: Double = 1.0
        
        while retryCount < maxRetries {
            do {
                return try await privateDatabase.save(record)
            } catch let error as CKError {
                retryCount += 1
                
                // 재시도 가능한 에러인지 확인
                let retryableErrors: [CKError.Code] = [
                    .networkFailure,
                    .networkUnavailable,
                    .serviceUnavailable,
                    .requestRateLimited,
                    .zoneBusy
                ]
                
                guard retryableErrors.contains(error.code) else {
                    throw error
                }
                
                // CloudKit 권장 재시도 시간 확인
                if let retryAfter = error.retryAfterSeconds {
                    delaySeconds = retryAfter
                }
                
                print("⏳ Retrying in \(delaySeconds)s (attempt \(retryCount)/\(maxRetries))")
                
                try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                
                // 지수 증가 (최대 60초)
                delaySeconds = min(delaySeconds * 2, 60)
            }
        }
        
        throw CloudKitError.maxRetriesExceeded
    }
}
