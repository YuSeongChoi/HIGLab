import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = self.view as? SKView else {
            return
        }
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        // Scene 생성 및 표시
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // presentScene으로 Scene을 View에 표시
        skView.presentScene(scene)
    }
}
