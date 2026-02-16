import AuthenticationServices

class AppleSignInManager {
    
    func createSignInRequest() -> ASAuthorizationAppleIDRequest {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        // 요청할 정보 범위 설정
        // scope를 지정하지 않으면 user identifier만 받음
        request.requestedScopes = [.fullName, .email]
        
        return request
    }
}
