import AuthenticationServices

extension AppleSignInManager {
    
    func extractEmail(
        from credential: ASAuthorizationAppleIDCredential
    ) -> String? {
        // email은 첫 인증 시에만 제공됨
        guard let email = credential.email else {
            print("이메일 없음 (재인증이거나 scope 미포함)")
            return nil
        }
        
        // 두 가지 형태:
        // 1. 실제 이메일: user@example.com
        // 2. Relay 이메일: abc123@privaterelay.appleid.com
        
        print("이메일: \(email)")
        
        // 반드시 저장! 재인증 시 다시 받을 수 없음
        saveEmail(email, forUser: credential.user)
        
        return email
    }
    
    private func saveEmail(_ email: String, forUser userID: String) {
        // 이메일 저장 로직
    }
}
