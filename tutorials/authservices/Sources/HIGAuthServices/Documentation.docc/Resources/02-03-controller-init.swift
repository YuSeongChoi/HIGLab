import AuthenticationServices

class AppleSignInManager {
    
    func startSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // ASAuthorizationController 초기화
        // 여러 인증 요청을 배열로 전달 가능
        let authorizationController = ASAuthorizationController(
            authorizationRequests: [request]
        )
        
        // 델리게이트 설정 (다음 단계에서 구현)
        // authorizationController.delegate = self
        // authorizationController.presentationContextProvider = self
    }
}
