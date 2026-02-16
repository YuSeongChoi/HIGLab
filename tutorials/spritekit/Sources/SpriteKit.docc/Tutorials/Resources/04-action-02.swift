import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
        
        // 회전 액션 (라디안 단위)
        // rotate(byAngle:duration:) - 상대적 회전
        let rotateBy = SKAction.rotate(byAngle: .pi, duration: 1.0)  // 180도 회전
        
        // rotate(toAngle:duration:) - 절대 각도로 회전
        let rotateTo = SKAction.rotate(toAngle: .pi / 2, duration: 1.0)  // 90도 위치로
        
        // 시계 방향 / 반시계 방향
        let clockwise = SKAction.rotate(byAngle: -.pi / 2, duration: 0.5)     // 시계 방향
        let counterClockwise = SKAction.rotate(byAngle: .pi / 2, duration: 0.5)  // 반시계
        
        // 무한 회전
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 1.0)
        let spinForever = SKAction.repeatForever(spin)
        
        sprite.run(spinForever)
    }
}
