import AuthenticationServices

extension AppleSignInManager {
    
    func extractIdentityToken(
        from credential: ASAuthorizationAppleIDCredential
    ) -> String? {
        // Identity Token은 Data 타입으로 제공됨
        guard let tokenData = credential.identityToken else {
            print("Identity Token이 없습니다")
            return nil
        }
        
        // UTF-8 문자열로 변환 (JWT 형식)
        guard let tokenString = String(data: tokenData, encoding: .utf8) else {
            print("토큰 변환 실패")
            return nil
        }
        
        // JWT 구조: header.payload.signature
        // 예: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOi...
        print("Identity Token: \(tokenString.prefix(50))...")
        
        // 이 토큰을 서버로 전송하여 검증합니다
        return tokenString
    }
}
