import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 뷰를 SKView로 캐스팅
        guard let skView = self.view as? SKView else {
            return
        }
        
        // SKView 설정
        skView.ignoresSiblingOrder = true
    }
}
