import AuthenticationServices

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential 
            as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        // 사용자 식별자 (항상 제공됨)
        // 이 값은 앱-사용자 조합에 대해 고유합니다
        let userIdentifier = credential.user
        
        // 예: "001234.abcdef1234567890.1234"
        print("User Identifier: \(userIdentifier)")
        
        // Keychain에 저장하여 재사용
        KeychainHelper.save(userIdentifier, forKey: "appleUserID")
    }
}

struct KeychainHelper {
    static func save(_ value: String, forKey key: String) {
        // Keychain 저장 구현
    }
}
