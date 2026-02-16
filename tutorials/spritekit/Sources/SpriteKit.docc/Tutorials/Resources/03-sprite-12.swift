import SpriteKit

class GameScene: SKScene {
    var character: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        setupCharacter()
        demonstrateTransformPropagation()
    }
    
    func setupCharacter() {
        // 부모 노드
        character = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 80))
        character.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(character)
        
        // 자식 노드들
        let hat = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 20))
        hat.position = CGPoint(x: 0, y: 50)
        character.addChild(hat)
        
        let weapon = SKSpriteNode(color: .gray, size: CGSize(width: 60, height: 10))
        weapon.position = CGPoint(x: 40, y: 0)
        character.addChild(weapon)
    }
    
    func demonstrateTransformPropagation() {
        // 부모 이동 → 자식도 함께 이동
        let moveRight = SKAction.moveBy(x: 100, y: 0, duration: 1.0)
        let moveLeft = SKAction.moveBy(x: -100, y: 0, duration: 1.0)
        let moveSequence = SKAction.sequence([moveRight, moveLeft])
        
        // 부모 회전 → 자식도 함께 회전
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        
        // 부모 스케일 → 자식도 함께 스케일
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        
        // 모든 변환을 그룹으로 실행
        let allActions = SKAction.group([
            SKAction.repeatForever(moveSequence),
            SKAction.repeatForever(rotate),
            SKAction.repeatForever(scaleSequence)
        ])
        
        character.run(allActions)
    }
}
