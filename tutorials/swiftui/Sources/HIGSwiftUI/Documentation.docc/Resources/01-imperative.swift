import UIKit

// 명령형(Imperative) 방식 - UIKit
class ViewController: UIViewController {
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 라벨 생성 (이미 위에서 했음)
        // 2. 텍스트 설정
        label.text = "Hello, UIKit!"
        // 3. 폰트 설정
        label.font = .systemFont(ofSize: 24, weight: .bold)
        // 4. 색상 설정
        label.textColor = .systemBlue
        // 5. 뷰에 추가
        view.addSubview(label)
        // 6. Auto Layout 설정
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// 총 12줄의 설정 코드가 필요합니다!
// "어떻게(How)" 만드는지를 하나하나 명령합니다.
