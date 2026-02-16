import AuthenticationServices
import UIKit

class ResponsiveLoginViewController: UIViewController {
    
    private func setupResponsiveButton() {
        let button = ASAuthorizationAppleIDButton(
            type: .signIn,
            style: .black
        )
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        // 반응형 Auto Layout 제약조건
        NSLayoutConstraint.activate([
            // 좌우 여백 40pt
            button.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 40
            ),
            button.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -40
            ),
            
            // 하단에서 100pt 위
            button.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -100
            ),
            
            // 최소 높이 50pt (HIG 권장)
            button.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 50
            ),
            
            // 최소 너비 140pt (HIG 필수)
            button.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 140
            )
        ])
    }
}
