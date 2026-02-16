import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 캐릭터 몸체 (부모 노드)
        let character = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 80))
        character.position = CGPoint(x: frame.midX, y: frame.midY)
        character.name = "character"
        addChild(character)
        
        // 모자 (자식 노드)
        let hat = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 20))
        hat.position = CGPoint(x: 0, y: 50)  // 부모 기준 상대 좌표
        hat.name = "hat"
        character.addChild(hat)
        
        // 무기 (자식 노드)
        let weapon = SKSpriteNode(color: .gray, size: CGSize(width: 60, height: 10))
        weapon.position = CGPoint(x: 40, y: 0)  // 오른쪽에 배치
        weapon.anchorPoint = CGPoint(x: 0, y: 0.5)  // 왼쪽 끝 기준
        weapon.name = "weapon"
        character.addChild(weapon)
        
        // 방패 (자식 노드)
        let shield = SKSpriteNode(color: .brown, size: CGSize(width: 20, height: 40))
        shield.position = CGPoint(x: -30, y: 0)  // 왼쪽에 배치
        shield.name = "shield"
        character.addChild(shield)
    }
}
