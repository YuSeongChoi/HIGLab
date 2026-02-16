import AuthenticationServices
import UIKit

// 밝은 배경에서 사용하는 버튼 스타일

class LightBackgroundViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButtons()
    }
    
    private func setupButtons() {
        // 옵션 1: .black 스타일 (강조)
        let blackButton = ASAuthorizationAppleIDButton(
            type: .signIn,
            style: .black
        )
        
        // 옵션 2: .whiteOutline 스타일 (미묘함)
        let outlineButton = ASAuthorizationAppleIDButton(
            type: .signIn,
            style: .whiteOutline
        )
        
        // 앱 디자인에 맞는 스타일 선택
        // .black은 눈에 더 잘 띔
        // .whiteOutline은 다른 버튼들과 조화롭게 어울림
    }
}
