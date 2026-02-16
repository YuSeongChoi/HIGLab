import AuthenticationServices
import UIKit

// 어두운 배경에서 사용하는 흰색 버튼

class DarkBackgroundViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupButton()
    }
    
    private func setupButton() {
        // .white 스타일 - 흰색 배경, 검은 텍스트
        // 어두운 배경에서 눈에 잘 띔
        let button = ASAuthorizationAppleIDButton(
            type: .signIn,
            style: .white
        )
        
        view.addSubview(button)
    }
}

// 스타일 종류:
// .black        → 검은 배경, 흰색 텍스트 (밝은 배경용)
// .white        → 흰색 배경, 검은 텍스트 (어두운 배경용)
// .whiteOutline → 흰색 배경, 검은 테두리 (밝은 배경용, 미묘한 스타일)
