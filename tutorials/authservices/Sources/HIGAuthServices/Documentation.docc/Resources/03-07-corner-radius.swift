import AuthenticationServices
import UIKit

class StyledLoginViewController: UIViewController {
    
    private func setupStyledButton() {
        let button = ASAuthorizationAppleIDButton(
            type: .signIn,
            style: .black
        )
        
        // cornerRadius 조절
        // 기본값은 시스템 기본 모서리 둥글기
        button.cornerRadius = 25  // 완전히 둥근 모서리
        // button.cornerRadius = 8  // 약간 둥근 모서리
        // button.cornerRadius = 0  // 각진 모서리
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 280),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
