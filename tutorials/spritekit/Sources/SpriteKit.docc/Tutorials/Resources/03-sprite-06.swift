import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 투명도 설정
        let sprite1 = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 100))
        sprite1.position = CGPoint(x: 100, y: frame.midY)
        sprite1.alpha = 0.5  // 50% 투명
        addChild(sprite1)
        
        // 색상 블렌드 (이미지 스프라이트에 색조 적용)
        let sprite2 = SKSpriteNode(imageNamed: "player")
        sprite2.position = CGPoint(x: 200, y: frame.midY)
        sprite2.color = .red                // 블렌드할 색상
        sprite2.colorBlendFactor = 0.5      // 0.0 = 원본, 1.0 = 완전히 색상으로
        addChild(sprite2)
        
        // 숨기기/보이기
        let sprite3 = SKSpriteNode(color: .green, size: CGSize(width: 100, height: 100))
        sprite3.position = CGPoint(x: 300, y: frame.midY)
        sprite3.isHidden = false  // true면 보이지 않음
        addChild(sprite3)
        
        // 블렌드 모드
        let sprite4 = SKSpriteNode(color: .yellow, size: CGSize(width: 80, height: 80))
        sprite4.position = CGPoint(x: 200, y: frame.midY + 100)
        sprite4.blendMode = .add  // 밝게 빛나는 효과
        addChild(sprite4)
    }
}
