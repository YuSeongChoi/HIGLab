import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
        
        // wait 액션으로 지연 추가
        let sequence = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.wait(forDuration: 1.0),           // 1초 대기
            SKAction.scale(to: 1.0, duration: 0.3),
            SKAction.wait(forDuration: 0.5),           // 0.5초 대기
            SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
        ])
        
        sprite.run(sequence)
        
        // 랜덤 대기 시간
        let randomWait = SKAction.wait(
            forDuration: 1.0,
            withRange: 0.5  // 0.75초 ~ 1.25초 사이 랜덤
        )
        
        // 적 스폰에 활용
        let spawnEnemy = SKAction.run {
            self.createEnemy()
        }
        
        let spawnSequence = SKAction.sequence([spawnEnemy, randomWait])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    func createEnemy() {
        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 30))
        enemy.position = CGPoint(
            x: CGFloat.random(in: 0...frame.width),
            y: frame.height + 20
        )
        addChild(enemy)
        
        let moveDown = SKAction.moveTo(y: -20, duration: 3.0)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveDown, remove]))
    }
}
