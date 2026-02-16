import SpriteKit

class GameScene: SKScene {
    var player: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: 100)
        addChild(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // 플레이어를 터치 위치로 이동
        movePlayerTo(location)
    }
    
    func movePlayerTo(_ destination: CGPoint) {
        // 현재 위치에서 목표까지 거리 계산
        let distance = hypot(
            destination.x - player.position.x,
            destination.y - player.position.y
        )
        
        // 거리에 비례한 이동 시간 (속도 일정하게)
        let speed: CGFloat = 300  // 포인트/초
        let duration = TimeInterval(distance / speed)
        
        // 진행 중인 이동 액션 취소
        player.removeAction(forKey: "moveAction")
        
        // 새 이동 액션 실행
        let moveAction = SKAction.move(to: destination, duration: duration)
        moveAction.timingMode = .easeOut
        player.run(moveAction, withKey: "moveAction")
    }
}
