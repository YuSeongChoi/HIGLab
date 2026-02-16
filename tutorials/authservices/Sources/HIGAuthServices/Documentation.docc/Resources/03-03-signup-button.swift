import AuthenticationServices
import UIKit

// 신규 사용자 유치 화면에 적합한 버튼

class SignUpViewController: UIViewController {
    
    private func setupSignUpButton() {
        // .signUp 타입 - "Sign up with Apple" 표시
        let button = ASAuthorizationAppleIDButton(
            type: .signUp,
            style: .black
        )
        
        button.addTarget(
            self,
            action: #selector(handleAppleSignUp),
            for: .touchUpInside
        )
        
        view.addSubview(button)
    }
    
    @objc private func handleAppleSignUp() {
        // 회원가입 흐름 시작
    }
}
