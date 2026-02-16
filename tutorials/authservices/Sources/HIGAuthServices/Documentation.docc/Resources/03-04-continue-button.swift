import AuthenticationServices
import UIKit

// 재방문 사용자에게 적합한 버튼

class WelcomeBackViewController: UIViewController {
    
    private func setupContinueButton() {
        // .continue 타입 - "Continue with Apple" 표시
        // 이미 가입한 사용자가 돌아왔을 때 자연스러운 UX
        let button = ASAuthorizationAppleIDButton(
            type: .continue,
            style: .black
        )
        
        button.addTarget(
            self,
            action: #selector(handleContinue),
            for: .touchUpInside
        )
        
        view.addSubview(button)
    }
    
    @objc private func handleContinue() {
        // 로그인 흐름 시작
    }
}

// 버튼 타입 정리:
// .signIn   → "Sign in with Apple"    (일반 로그인)
// .continue → "Continue with Apple"   (재방문 사용자)
// .signUp   → "Sign up with Apple"    (신규 가입)
// .default  → "Sign in with Apple"    (기본값)
