import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: 50, y: frame.midY)
        addChild(sprite)
        
        // 시퀀스: 액션들을 순차적으로 실행
        // 1번 끝나면 → 2번 → 3번 순서
        
        let moveRight = SKAction.moveBy(x: 100, y: 0, duration: 1.0)
        let wait = SKAction.wait(forDuration: 0.5)
        let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 1.0)
        let moveLeft = SKAction.moveBy(x: -100, y: 0, duration: 1.0)
        let moveDown = SKAction.moveBy(x: 0, y: -100, duration: 1.0)
        
        // 사각형 경로로 이동
        let squarePath = SKAction.sequence([
            moveRight,
            wait,
            moveUp,
            wait,
            moveLeft,
            wait,
            moveDown
        ])
        
        // 무한 반복
        let repeatSquare = SKAction.repeatForever(squarePath)
        
        sprite.run(repeatSquare)
    }
}
