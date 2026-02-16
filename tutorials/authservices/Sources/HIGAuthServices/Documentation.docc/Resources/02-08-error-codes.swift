import AuthenticationServices

// ASAuthorizationError.Code 종류

enum AuthErrorHandling {
    
    static func handle(_ error: ASAuthorizationError) -> String {
        switch error.code {
            
        case .canceled:
            // 사용자가 인증을 취소함
            // UI 업데이트 불필요, 조용히 처리
            return ""
            
        case .failed:
            // 인증 시도 실패
            // 네트워크 오류, 서버 오류 등
            return "로그인에 실패했습니다. 다시 시도해주세요."
            
        case .invalidResponse:
            // Apple 서버로부터 잘못된 응답
            return "서버 응답 오류가 발생했습니다."
            
        case .notHandled:
            // 요청이 처리되지 않음
            return "요청을 처리할 수 없습니다."
            
        case .notInteractive:
            // UI 표시 없이 자격 증명 사용 시도 실패
            return "자동 로그인에 실패했습니다."
            
        case .unknown:
            // 알 수 없는 오류
            return "알 수 없는 오류가 발생했습니다."
            
        @unknown default:
            return "오류가 발생했습니다."
        }
    }
}
