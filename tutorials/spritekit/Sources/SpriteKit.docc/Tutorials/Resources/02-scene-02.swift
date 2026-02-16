import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = self.view as? SKView else {
            return
        }
        
        // 디버그 정보 활성화
        skView.showsFPS = true           // 프레임 레이트 표시
        skView.showsNodeCount = true     // 노드 개수 표시
        skView.showsDrawCount = true     // 드로우 콜 수 표시
        skView.showsPhysics = true       // 물리 바디 시각화
        
        skView.ignoresSiblingOrder = true
    }
}
