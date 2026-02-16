import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: 100, y: frame.midY)
        addChild(sprite)
        
        // 이동 액션 생성
        // move(to:duration:) - 지정 위치로 이동
        let moveToRight = SKAction.move(to: CGPoint(x: 300, y: frame.midY), duration: 2.0)
        
        // 액션 실행
        sprite.run(moveToRight)
        
        // move(by:duration:) - 상대적 이동
        let moveBy = SKAction.move(by: CGVector(dx: 100, dy: 50), duration: 1.0)
        
        // moveTo(x:duration:) / moveTo(y:duration:) - 특정 축만 이동
        let moveToX = SKAction.moveTo(x: 200, duration: 1.0)
        let moveToY = SKAction.moveTo(y: 400, duration: 1.0)
    }
}
