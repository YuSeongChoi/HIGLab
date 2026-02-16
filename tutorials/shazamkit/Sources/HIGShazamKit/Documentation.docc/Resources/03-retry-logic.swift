import ShazamKit

@available(iOS 17.0, *)
class RetryingMatcher {
    private let session = SHManagedSession()
    private let maxRetries = 3
    
    /// 지수 백오프로 재시도하는 매칭
    func matchWithRetry() async -> SHSession.Result {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            let result = await session.result()
            
            switch result {
            case .match, .noMatch:
                // 성공 또는 매칭 없음 - 재시도 불필요
                return result
                
            case .error(let error, _):
                lastError = error
                
                // 네트워크 에러만 재시도
                if !isRetryableError(error) {
                    return result
                }
                
                // 지수 백오프 대기
                let delay = pow(2.0, Double(attempt))  // 1, 2, 4초
                try? await Task.sleep(for: .seconds(delay))
                
                print("재시도 \(attempt + 1)/\(maxRetries)")
            }
        }
        
        // 모든 재시도 실패
        return .error(lastError ?? SHError(.matchAttemptFailed), nil)
    }
    
    private func isRetryableError(_ error: Error) -> Bool {
        // 네트워크 에러만 재시도
        if let shError = error as? SHError {
            return shError.code == .matchAttemptFailed
        }
        return (error as NSError).domain == NSURLErrorDomain
    }
}
