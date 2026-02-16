import AuthenticationServices

extension AppleSignInManager {
    
    func handleReAuthentication(
        _ credential: ASAuthorizationAppleIDCredential
    ) {
        let userIdentifier = credential.user
        
        // 재인증 시 email, fullName은 nil
        // 저장된 정보와 매칭
        
        if let savedCredentials = KeychainManager.loadCredentials(
            userIdentifier: userIdentifier
        ) {
            // 저장된 정보로 세션 생성
            print("Welcome back, \(savedCredentials.firstName ?? "User")!")
            
            createSession(
                userID: userIdentifier,
                email: savedCredentials.email,
                name: savedCredentials.firstName
            )
        } else {
            // 저장된 정보가 없는 경우
            // 사용자에게 추가 정보 입력 요청할 수 있음
            print("추가 정보가 필요합니다")
            requestAdditionalInfo(userID: userIdentifier)
        }
    }
    
    private func createSession(
        userID: String, 
        email: String?, 
        name: String?
    ) {
        // 세션 생성 로직
    }
    
    private func requestAdditionalInfo(userID: String) {
        // 추가 정보 입력 UI 표시
    }
}
