import SpriteKit

enum SwipeDirection {
    case up, down, left, right
}

class GameScene: SKScene {
    var touchStartPosition: CGPoint?
    var player: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchStartPosition = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let startPos = touchStartPosition else { return }
        
        let endPos = touch.location(in: self)
        
        if let direction = detectSwipeDirection(from: startPos, to: endPos) {
            handleSwipe(direction)
        }
        
        touchStartPosition = nil
    }
    
    func detectSwipeDirection(from start: CGPoint, to end: CGPoint) -> SwipeDirection? {
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        let minDistance: CGFloat = 50
        
        // 수평 스와이프가 더 긴 경우
        if abs(dx) > abs(dy) && abs(dx) > minDistance {
            return dx > 0 ? .right : .left
        }
        // 수직 스와이프가 더 긴 경우
        else if abs(dy) > abs(dx) && abs(dy) > minDistance {
            return dy > 0 ? .up : .down
        }
        
        return nil
    }
    
    func handleSwipe(_ direction: SwipeDirection) {
        let moveDistance: CGFloat = 100
        var moveVector: CGVector
        
        switch direction {
        case .up:
            moveVector = CGVector(dx: 0, dy: moveDistance)
            print("위로 스와이프!")
        case .down:
            moveVector = CGVector(dx: 0, dy: -moveDistance)
            print("아래로 스와이프!")
        case .left:
            moveVector = CGVector(dx: -moveDistance, dy: 0)
            print("왼쪽으로 스와이프!")
        case .right:
            moveVector = CGVector(dx: moveDistance, dy: 0)
            print("오른쪽으로 스와이프!")
        }
        
        let move = SKAction.move(by: moveVector, duration: 0.2)
        move.timingMode = .easeOut
        player.run(move)
    }
}
