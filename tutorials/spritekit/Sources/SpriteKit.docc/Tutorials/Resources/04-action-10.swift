import SpriteKit

class GameScene: SKScene {
    var score = 0
    var scoreLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setupUI()
        
        let coin = SKSpriteNode(color: .yellow, size: CGSize(width: 30, height: 30))
        coin.position = CGPoint(x: frame.midX, y: frame.midY)
        coin.name = "coin"
        addChild(coin)
        
        // run 액션으로 코드 블록 실행
        let collectCoin = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 0.0, duration: 0.2),
            SKAction.run { [weak self] in
                // 점수 증가
                self?.score += 100
                self?.updateScoreLabel()
            },
            SKAction.removeFromParent()
        ])
        
        // 2초 후 수집 시뮬레이션
        let wait = SKAction.wait(forDuration: 2.0)
        coin.run(SKAction.sequence([wait, collectCoin]))
    }
    
    func setupUI() {
        scoreLabel = SKLabelNode(text: "점수: 0")
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(scoreLabel)
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "점수: \(score)"
        
        // 점수 레이블 강조 효과
        let emphasize = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        scoreLabel.run(emphasize)
    }
}
