import AuthenticationServices
import UIKit

class LoginViewController: UIViewController {
    // ViewController에서 직접 구현하는 경우
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        // 현재 ViewController의 윈도우 반환
        // 인증 시트가 이 윈도우 위에 표시됩니다
        return self.view.window!
    }
}

// 또는 별도 매니저 클래스에서 사용하는 경우
class AppleSignInManager: NSObject, 
    ASAuthorizationControllerPresentationContextProviding {
    
    weak var presentingWindow: UIWindow?
    
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        return presentingWindow!
    }
}
