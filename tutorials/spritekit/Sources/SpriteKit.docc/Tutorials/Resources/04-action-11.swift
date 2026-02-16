import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
        
        // 사운드 액션 (waitForCompletion: 사운드 끝날 때까지 대기 여부)
        let playSound = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
        
        // 점프 + 사운드
        let jump = SKAction.sequence([
            SKAction.group([
                playSound,
                SKAction.moveBy(x: 0, y: 100, duration: 0.3)
            ]),
            SKAction.moveBy(x: 0, y: -100, duration: 0.3)
        ])
        
        // 2초마다 점프
        let jumpLoop = SKAction.sequence([jump, SKAction.wait(forDuration: 2.0)])
        sprite.run(SKAction.repeatForever(jumpLoop))
        
        // 폭발 효과 (사운드 + 비주얼)
        let explosion = SKAction.sequence([
            SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false),
            SKAction.group([
                SKAction.scale(to: 3.0, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.removeFromParent()
        ])
        
        // explosion을 사용하여 적 제거
    }
}
