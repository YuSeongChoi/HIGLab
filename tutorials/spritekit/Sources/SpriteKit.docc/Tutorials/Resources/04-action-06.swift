import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
        
        // 반복 액션
        let jump = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 50, duration: 0.3),
            SKAction.moveBy(x: 0, y: -50, duration: 0.3)
        ])
        
        // 특정 횟수만 반복
        let jumpThreeTimes = SKAction.repeat(jump, count: 3)
        
        // 무한 반복
        let jumpForever = SKAction.repeatForever(jump)
        
        // 반복 후 다른 액션 실행
        let celebration = SKAction.sequence([
            jumpThreeTimes,
            SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
        ])
        
        sprite.run(celebration)
        
        // 역방향 액션 만들기
        let moveRight = SKAction.moveBy(x: 100, y: 0, duration: 1.0)
        let moveLeft = moveRight.reversed()  // 반대 방향으로 이동
        
        let pingPong = SKAction.sequence([moveRight, moveLeft])
        // sprite.run(SKAction.repeatForever(pingPong))
    }
}
