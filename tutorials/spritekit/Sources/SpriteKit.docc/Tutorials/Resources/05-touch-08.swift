import SpriteKit

class GameScene: SKScene {
    var touchStartPosition: CGPoint?
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        let instruction = SKLabelNode(text: "스와이프해 보세요!")
        instruction.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(instruction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // 터치 시작 위치 저장
        touchStartPosition = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let startPosition = touchStartPosition else { return }
        
        let endPosition = touch.location(in: self)
        
        // 이동 거리 계산
        let dx = endPosition.x - startPosition.x
        let dy = endPosition.y - startPosition.y
        
        // 최소 스와이프 거리
        let minSwipeDistance: CGFloat = 50
        
        if abs(dx) > minSwipeDistance || abs(dy) > minSwipeDistance {
            // 스와이프 감지됨
            print("스와이프! dx: \(dx), dy: \(dy)")
        }
        
        touchStartPosition = nil
    }
}
