import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 배경 노드 추가
        let background = SKSpriteNode(color: .darkGray, size: self.size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
        
        // 플레이어 노드 추가
        let player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(player)
        
        // 레이블 노드 추가
        let scoreLabel = SKLabelNode(text: "점수: 0")
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(scoreLabel)
    }
}
