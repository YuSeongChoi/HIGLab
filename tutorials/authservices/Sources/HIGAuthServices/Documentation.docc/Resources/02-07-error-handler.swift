import AuthenticationServices

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        // 인증 실패 또는 취소
        
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                // 사용자가 취소함 - 오류 메시지 표시 불필요
                print("사용자가 로그인을 취소했습니다")
                
            case .failed:
                // 인증 실패
                print("인증에 실패했습니다: \(error.localizedDescription)")
                showError("로그인에 실패했습니다. 다시 시도해주세요.")
                
            case .invalidResponse:
                // 잘못된 응답
                print("잘못된 응답을 받았습니다")
                showError("서버 오류가 발생했습니다.")
                
            case .notHandled:
                // 처리되지 않음
                print("요청이 처리되지 않았습니다")
                
            default:
                print("알 수 없는 오류: \(error)")
            }
        }
    }
    
    private func showError(_ message: String) {
        // 오류 UI 표시
    }
}
