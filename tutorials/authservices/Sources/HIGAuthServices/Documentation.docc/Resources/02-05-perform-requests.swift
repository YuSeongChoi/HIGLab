import AuthenticationServices
import UIKit

class AppleSignInManager: NSObject {
    
    func startSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(
            authorizationRequests: [request]
        )
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        // 인증 흐름 시작!
        // 시스템이 자동으로 인증 UI를 표시합니다
        authorizationController.performRequests()
    }
}
