import AuthenticationServices

extension AppleSignInManager {
    
    func extractAuthorizationCode(
        from credential: ASAuthorizationAppleIDCredential
    ) -> String? {
        // Authorization Code 추출
        guard let codeData = credential.authorizationCode else {
            print("Authorization Code가 없습니다")
            return nil
        }
        
        guard let codeString = String(data: codeData, encoding: .utf8) else {
            print("코드 변환 실패")
            return nil
        }
        
        // Authorization Code는 일회용입니다
        // 서버에서 Apple과 교환하여 refresh token을 얻습니다
        return codeString
    }
    
    // 서버로 전송
    func sendToServer(
        identityToken: String,
        authorizationCode: String,
        userIdentifier: String
    ) {
        // API 요청으로 서버에 전송
        // 서버에서 토큰 검증 및 세션 생성
    }
}
