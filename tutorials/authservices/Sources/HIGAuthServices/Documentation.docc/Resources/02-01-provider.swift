import AuthenticationServices

class AppleSignInManager {
    
    func startSignIn() {
        // Apple ID Provider 생성
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        // 인증 요청 생성
        let request = appleIDProvider.createRequest()
        
        // 요청할 정보 범위 설정
        request.requestedScopes = [.fullName, .email]
        
        // 이제 이 request로 ASAuthorizationController를 생성합니다
    }
}
