import AuthenticationServices

extension AppleSignInManager {
    
    func handleCredential(_ credential: ASAuthorizationAppleIDCredential) {
        let userIdentifier = credential.user
        
        // email과 fullName은 첫 인증 시에만 제공됨!
        // nil이 아니면 첫 인증입니다
        
        if let email = credential.email,
           let fullName = credential.fullName {
            
            // 첫 인증 - 정보 저장 필수!
            print("첫 인증 - 사용자 정보 저장")
            
            let firstName = fullName.givenName ?? ""
            let lastName = fullName.familyName ?? ""
            
            // 반드시 저장 (재인증 시 받을 수 없음)
            saveUserInfo(
                userID: userIdentifier,
                email: email,
                firstName: firstName,
                lastName: lastName
            )
        } else {
            // 재인증 - 저장된 정보 사용
            print("재인증 - 저장된 정보 조회")
            let savedInfo = loadUserInfo(userID: userIdentifier)
        }
    }
    
    func saveUserInfo(userID: String, email: String, 
                      firstName: String, lastName: String) {
        // 저장 로직
    }
    
    func loadUserInfo(userID: String) -> UserInfo? {
        return nil
    }
}

struct UserInfo {
    let email: String
    let firstName: String
    let lastName: String
}
