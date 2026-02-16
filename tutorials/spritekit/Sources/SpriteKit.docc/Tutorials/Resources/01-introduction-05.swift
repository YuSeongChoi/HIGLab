import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 앵커 포인트 예시
        
        // 기본 앵커 포인트 (0.5, 0.5) - 중앙
        let sprite1 = SKSpriteNode(color: .blue, size: CGSize(width: 80, height: 80))
        sprite1.position = CGPoint(x: 100, y: 300)
        sprite1.anchorPoint = CGPoint(x: 0.5, y: 0.5)  // 기본값
        addChild(sprite1)
        
        // 앵커 포인트 (0, 0) - 왼쪽 하단
        let sprite2 = SKSpriteNode(color: .green, size: CGSize(width: 80, height: 80))
        sprite2.position = CGPoint(x: 100, y: 200)
        sprite2.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(sprite2)
        
        // 앵커 포인트 (1, 1) - 오른쪽 상단
        let sprite3 = SKSpriteNode(color: .red, size: CGSize(width: 80, height: 80))
        sprite3.position = CGPoint(x: 100, y: 100)
        sprite3.anchorPoint = CGPoint(x: 1, y: 1)
        addChild(sprite3)
        
        // 앵커 포인트는 회전과 스케일의 기준점이 됩니다
    }
}
