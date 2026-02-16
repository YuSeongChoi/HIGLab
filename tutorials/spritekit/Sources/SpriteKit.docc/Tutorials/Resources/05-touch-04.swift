import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        // 터치 가능한 노드들 생성
        for i in 0..<5 {
            let sprite = SKSpriteNode(color: .random, size: CGSize(width: 60, height: 60))
            sprite.position = CGPoint(x: 80 + i * 70, y: Int(frame.midY))
            sprite.name = "box_\(i)"
            addChild(sprite)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // 터치 위치의 모든 노드 가져오기
        let touchedNodes = nodes(at: location)
        
        print("터치된 노드 수: \(touchedNodes.count)")
        
        for node in touchedNodes {
            print("노드 이름: \(node.name ?? "이름 없음")")
        }
    }
}

// UIColor 랜덤 확장
extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}
