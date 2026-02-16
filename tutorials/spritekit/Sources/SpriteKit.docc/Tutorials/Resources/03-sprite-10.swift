import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 앵커 포인트 비교
        
        // 기본값 (0.5, 0.5) - 중앙
        let sprite1 = createSprite(color: .blue, anchorPoint: CGPoint(x: 0.5, y: 0.5))
        sprite1.position = CGPoint(x: 100, y: 400)
        addChild(sprite1)
        addAnchorMarker(to: sprite1)
        
        // (0, 0) - 왼쪽 하단 (게임 타일에 유용)
        let sprite2 = createSprite(color: .green, anchorPoint: CGPoint(x: 0, y: 0))
        sprite2.position = CGPoint(x: 100, y: 250)
        addChild(sprite2)
        addAnchorMarker(to: sprite2)
        
        // (0.5, 0) - 하단 중앙 (캐릭터의 발 기준)
        let sprite3 = createSprite(color: .red, anchorPoint: CGPoint(x: 0.5, y: 0))
        sprite3.position = CGPoint(x: 100, y: 100)
        addChild(sprite3)
        addAnchorMarker(to: sprite3)
    }
    
    func createSprite(color: UIColor, anchorPoint: CGPoint) -> SKSpriteNode {
        let sprite = SKSpriteNode(color: color, size: CGSize(width: 80, height: 80))
        sprite.anchorPoint = anchorPoint
        return sprite
    }
    
    func addAnchorMarker(to sprite: SKSpriteNode) {
        // 앵커 포인트 위치에 작은 점 표시
        let marker = SKShapeNode(circleOfRadius: 5)
        marker.fillColor = .white
        marker.position = .zero  // 부모의 앵커 포인트 위치
        sprite.addChild(marker)
    }
}
