import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 100))
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
        
        // 균일한 크기 조절
        sprite.setScale(1.5)  // 1.5배 크기
        
        // 개별 축 스케일
        // sprite.xScale = 2.0  // 가로 2배
        // sprite.yScale = 0.5  // 세로 0.5배
        
        // 회전 (라디안 단위)
        sprite.zRotation = .pi / 4  // 45도 회전
        
        // 도(degree)를 라디안으로 변환하는 유틸리티
        func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
            return degrees * .pi / 180
        }
        
        // 90도 회전
        let anotherSprite = SKSpriteNode(color: .green, size: CGSize(width: 80, height: 40))
        anotherSprite.position = CGPoint(x: 100, y: 200)
        anotherSprite.zRotation = degreesToRadians(90)
        addChild(anotherSprite)
    }
}
