import SpriteKit

class GameScene: SKScene {
    var selectedNode: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        // 드래그 가능한 노드들
        for i in 0..<3 {
            let box = SKSpriteNode(color: .random, size: CGSize(width: 80, height: 80))
            box.position = CGPoint(x: 100 + i * 120, y: Int(frame.midY))
            box.name = "draggable"
            addChild(box)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // 드래그할 노드 찾기
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if let sprite = node as? SKSpriteNode, sprite.name == "draggable" {
                selectedNode = sprite
                // 선택 효과
                sprite.run(SKAction.scale(to: 1.1, duration: 0.1))
                // 앞으로 가져오기
                sprite.zPosition = 100
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let selected = selectedNode else { return }
        
        // 노드를 터치 위치로 이동
        let location = touch.location(in: self)
        selected.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let selected = selectedNode else { return }
        
        // 선택 해제 효과
        selected.run(SKAction.scale(to: 1.0, duration: 0.1))
        selected.zPosition = 0
        selectedNode = nil
    }
}
