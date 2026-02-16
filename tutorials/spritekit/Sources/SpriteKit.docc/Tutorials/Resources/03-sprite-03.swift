import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 플레이어 스프라이트 생성
        let player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        
        // 위치 설정 (x, y 좌표)
        player.position = CGPoint(x: frame.midX, y: 100)
        
        // 이름 설정 (나중에 찾기 위해)
        player.name = "player"
        
        // Scene에 추가
        addChild(player)
        
        // 다른 스프라이트들 추가
        let enemy1 = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        enemy1.position = CGPoint(x: 100, y: 400)
        enemy1.name = "enemy"
        addChild(enemy1)
        
        let enemy2 = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        enemy2.position = CGPoint(x: 275, y: 400)
        enemy2.name = "enemy"
        addChild(enemy2)
        
        // 이름으로 노드 찾기
        if let foundPlayer = childNode(withName: "player") as? SKSpriteNode {
            print("플레이어를 찾았습니다: \(foundPlayer)")
        }
    }
}
