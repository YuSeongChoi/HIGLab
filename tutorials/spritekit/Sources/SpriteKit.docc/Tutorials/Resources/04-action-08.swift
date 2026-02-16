import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        sprite.position = CGPoint(x: 50, y: frame.midY)
        addChild(sprite)
        
        // 커스텀 타이밍 함수
        let moveAction = SKAction.moveTo(x: 325, duration: 2.0)
        
        // timingFunction: 0.0 ~ 1.0 사이의 시간을 입력받아
        // 0.0 ~ 1.0 사이의 진행률을 반환
        moveAction.timingFunction = { time in
            // 바운스 효과 (탄성 있는 움직임)
            let c4 = (2 * Float.pi) / 3
            if time == 0 { return 0 }
            if time == 1 { return 1 }
            return pow(2, -10 * time) * sin((time * 10 - 0.75) * c4) + 1
        }
        
        sprite.run(moveAction)
        
        // 다른 예시: 급격한 시작, 부드러운 끝
        let sprite2 = SKSpriteNode(color: .orange, size: CGSize(width: 50, height: 50))
        sprite2.position = CGPoint(x: 50, y: frame.midY - 100)
        addChild(sprite2)
        
        let moveAction2 = SKAction.moveTo(x: 325, duration: 2.0)
        moveAction2.timingFunction = { time in
            return 1 - pow(1 - time, 3)  // Cubic ease out
        }
        
        sprite2.run(moveAction2)
    }
}
