import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 여러 스프라이트로 타이밍 모드 비교
        let yPositions: [CGFloat] = [400, 300, 200, 100]
        let timingModes: [SKActionTimingMode] = [.linear, .easeIn, .easeOut, .easeInEaseOut]
        let colors: [UIColor] = [.red, .green, .blue, .yellow]
        
        for (index, timingMode) in timingModes.enumerated() {
            let sprite = SKSpriteNode(color: colors[index], size: CGSize(width: 40, height: 40))
            sprite.position = CGPoint(x: 50, y: yPositions[index])
            addChild(sprite)
            
            // 이동 액션
            var moveAction = SKAction.moveTo(x: 325, duration: 2.0)
            
            // 타이밍 모드 설정
            moveAction.timingMode = timingMode
            
            // .linear: 일정한 속도
            // .easeIn: 천천히 시작, 점점 빨라짐
            // .easeOut: 빠르게 시작, 점점 느려짐
            // .easeInEaseOut: 천천히 시작 → 빨라짐 → 천천히 끝남
            
            sprite.run(moveAction)
        }
        
        // 레이블 추가
        addLabel("Linear", at: CGPoint(x: 50, y: 430))
        addLabel("Ease In", at: CGPoint(x: 50, y: 330))
        addLabel("Ease Out", at: CGPoint(x: 50, y: 230))
        addLabel("Ease In Out", at: CGPoint(x: 50, y: 130))
    }
    
    func addLabel(_ text: String, at position: CGPoint) {
        let label = SKLabelNode(text: text)
        label.fontSize = 14
        label.position = position
        addChild(label)
    }
}
