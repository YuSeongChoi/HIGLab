import AuthenticationServices
import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleSignInButton()
    }
    
    private func setupAppleSignInButton() {
        // ASAuthorizationAppleIDButton 생성
        // 타입: .signIn (기본 로그인)
        // 스타일: .black (검은 배경)
        let button = ASAuthorizationAppleIDButton(
            type: .signIn,
            style: .black
        )
        
        // 버튼 크기 설정
        button.frame = CGRect(x: 0, y: 0, width: 280, height: 50)
        button.center = view.center
        
        view.addSubview(button)
    }
}
