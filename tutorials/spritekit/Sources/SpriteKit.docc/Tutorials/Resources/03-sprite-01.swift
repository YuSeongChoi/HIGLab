import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 이미지로 스프라이트 생성
        // Assets 카탈로그에 "player" 이미지가 있어야 합니다
        let player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(player)
        
        // 텍스처 객체를 먼저 생성하는 방법
        let enemyTexture = SKTexture(imageNamed: "enemy")
        let enemy = SKSpriteNode(texture: enemyTexture)
        enemy.position = CGPoint(x: frame.midX + 100, y: frame.midY)
        addChild(enemy)
    }
}
