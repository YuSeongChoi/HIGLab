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
        
        // 두 가지 delegate 설정 필요
        
        // 1. 인증 결과 처리용
        authorizationController.delegate = self
        
        // 2. 인증 UI 표시 위치 지정용
        authorizationController.presentationContextProvider = self
    }
}

// 프로토콜 채택 (다음 단계에서 구현)
extension AppleSignInManager: ASAuthorizationControllerDelegate {
    // 인증 성공/실패 처리
}

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    // 표시할 윈도우 제공
}
