import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // Scene 중앙에 스프라이트 배치
        let centerX = frame.midX  // Scene의 가로 중앙
        let centerY = frame.midY  // Scene의 세로 중앙
        
        let sprite = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        sprite.position = CGPoint(x: centerX, y: centerY)
        addChild(sprite)
        
        // 좌표 시스템 확인
        // (0, 0)은 왼쪽 하단
        // y값이 증가할수록 위로 올라감
        print("Scene 크기: \(frame.size)")
        print("중앙 좌표: (\(centerX), \(centerY))")
    }
}
