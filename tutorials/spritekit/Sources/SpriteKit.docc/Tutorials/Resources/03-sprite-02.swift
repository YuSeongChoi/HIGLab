import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 색상과 크기로 스프라이트 생성 (이미지 없이)
        let blueBox = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 100))
        blueBox.position = CGPoint(x: frame.midX - 100, y: frame.midY)
        addChild(blueBox)
        
        // 다양한 크기의 스프라이트
        let smallBox = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 30))
        smallBox.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(smallBox)
        
        let largeBox = SKSpriteNode(color: .green, size: CGSize(width: 150, height: 80))
        largeBox.position = CGPoint(x: frame.midX + 100, y: frame.midY)
        addChild(largeBox)
    }
}
