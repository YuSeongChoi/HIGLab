import SpriteKit

class GameScene: SKScene {
    // Scene 속성
    var player: SKSpriteNode?
    var score: Int = 0
    
    // Scene이 초기화될 때 호출
    override func sceneDidLoad() {
        // Scene 파일(.sks)에서 로드된 직후
        // 아직 View에 연결되지 않은 상태
    }
}
