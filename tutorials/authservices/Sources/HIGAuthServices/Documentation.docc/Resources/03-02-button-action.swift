import AuthenticationServices
import UIKit

class LoginViewController: UIViewController {
    
    private func setupAppleSignInButton() {
        let button = ASAuthorizationAppleIDButton(
            type: .signIn,
            style: .black
        )
        
        // 버튼 탭 액션 연결
        button.addTarget(
            self,
            action: #selector(handleAppleSignIn),
            for: .touchUpInside
        )
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        // Auto Layout
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 280),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func handleAppleSignIn() {
        // 인증 흐름 시작
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(
            authorizationRequests: [request]
        )
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}
