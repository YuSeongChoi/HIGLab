import AuthenticationServices

extension AppleSignInManager {
    
    func extractName(
        from credential: ASAuthorizationAppleIDCredential
    ) -> (firstName: String?, lastName: String?) {
        
        guard let fullName = credential.fullName else {
            // fullName이 nil이면 재인증
            return (nil, nil)
        }
        
        // PersonNameComponents 구조
        let firstName = fullName.givenName    // 이름 (First Name)
        let lastName = fullName.familyName    // 성 (Last Name)
        let middleName = fullName.middleName  // 중간 이름
        let prefix = fullName.namePrefix      // Dr., Mr. 등
        let suffix = fullName.nameSuffix      // Jr., III 등
        let nickname = fullName.nickname      // 별명
        
        print("이름: \(firstName ?? "없음")")
        print("성: \(lastName ?? "없음")")
        
        return (firstName, lastName)
    }
}
