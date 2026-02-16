import SpriteKit

class GameScene: SKScene {
    var touchMarkers: [UITouch: SKShapeNode] = [:]
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        let label = SKLabelNode(text: "멀티터치를 시도해 보세요!")
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 모든 터치를 순회
        for touch in touches {
            let location = touch.location(in: self)
            
            // 각 터치에 마커 생성
            let marker = SKShapeNode(circleOfRadius: 30)
            marker.fillColor = .random
            marker.strokeColor = .white
            marker.lineWidth = 2
            marker.position = location
            addChild(marker)
            
            // 터치와 마커 연결
            touchMarkers[touch] = marker
            
            print("터치 추가됨. 현재 터치 수: \(touchMarkers.count)")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // 해당 터치의 마커 이동
            if let marker = touchMarkers[touch] {
                marker.position = location
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // 마커 제거
            if let marker = touchMarkers[touch] {
                marker.removeFromParent()
                touchMarkers.removeValue(forKey: touch)
            }
            
            print("터치 종료. 남은 터치 수: \(touchMarkers.count)")
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
