import AuthenticationServices

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        // 인증 성공!
        // credential 타입을 확인하여 처리
        
        if let appleIDCredential = authorization.credential 
            as? ASAuthorizationAppleIDCredential {
            
            // Apple ID 로그인 성공
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("User ID: \(userIdentifier)")
            print("Name: \(fullName?.givenName ?? "N/A")")
            print("Email: \(email ?? "N/A")")
            
            // 서버에 전송하거나 로컬에 저장
            handleSuccessfulSignIn(credential: appleIDCredential)
        }
    }
    
    private func handleSuccessfulSignIn(
        credential: ASAuthorizationAppleIDCredential
    ) {
        // 로그인 처리 로직
    }
}
