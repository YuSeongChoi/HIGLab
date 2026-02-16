import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
        
        // 페이드 액션
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)        // 사라짐
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)          // 나타남
        let fadeTo = SKAction.fadeAlpha(to: 0.5, duration: 0.5)  // 특정 투명도로
        
        // 스케일 액션
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.5)     // 2배로
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.5)   // 0.5배로
        let scaleBy = SKAction.scale(by: 1.5, duration: 0.5)     // 현재의 1.5배
        
        // 개별 축 스케일
        let scaleX = SKAction.scaleX(to: 2.0, duration: 0.5)
        let scaleY = SKAction.scaleY(to: 0.5, duration: 0.5)
        
        // 펄스 효과 (커졌다 작아졌다)
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        let pulseForever = SKAction.repeatForever(pulse)
        
        sprite.run(pulseForever)
    }
}
