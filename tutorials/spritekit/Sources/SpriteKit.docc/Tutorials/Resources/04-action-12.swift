import SpriteKit

class GameScene: SKScene {
    var player: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(player)
        
        // 키와 함께 액션 실행
        let idle = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        player.run(SKAction.repeatForever(idle), withKey: "idleAnimation")
        
        // 회전 애니메이션 추가
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        player.run(SKAction.repeatForever(spin), withKey: "spinAnimation")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 특정 액션이 실행 중인지 확인
        if player.action(forKey: "idleAnimation") != nil {
            print("idle 애니메이션 실행 중")
        }
        
        // 특정 액션만 중지
        player.removeAction(forKey: "spinAnimation")
        
        // 모든 액션 중지
        // player.removeAllActions()
        
        // 새 액션 시작 (같은 키면 이전 것을 교체)
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let moveDown = moveUp.reversed()
        player.run(SKAction.sequence([moveUp, moveDown]), withKey: "jumpAction")
    }
    
    // 액션 완료 시 콜백
    func performActionWithCompletion() {
        let move = SKAction.moveBy(x: 100, y: 0, duration: 1.0)
        player.run(move) {
            print("이동 완료!")
            // 완료 후 로직
        }
    }
}
