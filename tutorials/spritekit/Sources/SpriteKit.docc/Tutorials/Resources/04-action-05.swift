import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
        
        // 그룹: 여러 액션을 동시에 실행
        // 모든 액션이 동시에 시작됨
        
        let move = SKAction.moveBy(x: 100, y: 100, duration: 2.0)
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        let scale = SKAction.scale(to: 1.5, duration: 2.0)
        let fade = SKAction.fadeAlpha(to: 0.5, duration: 2.0)
        
        // 이동하면서 회전하면서 커지면서 투명해짐 (동시에!)
        let combined = SKAction.group([move, rotate, scale, fade])
        
        // 원래대로 돌아오기
        let moveBack = SKAction.moveBy(x: -100, y: -100, duration: 2.0)
        let rotateBack = SKAction.rotate(byAngle: -.pi * 2, duration: 2.0)
        let scaleBack = SKAction.scale(to: 1.0, duration: 2.0)
        let fadeBack = SKAction.fadeAlpha(to: 1.0, duration: 2.0)
        let combinedBack = SKAction.group([moveBack, rotateBack, scaleBack, fadeBack])
        
        // 왕복 반복
        let fullSequence = SKAction.sequence([combined, combinedBack])
        sprite.run(SKAction.repeatForever(fullSequence))
    }
}
