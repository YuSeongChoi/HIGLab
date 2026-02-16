import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        // 터치 위치 표시용 마커
        let marker = SKShapeNode(circleOfRadius: 10)
        marker.fillColor = .yellow
        marker.name = "marker"
        marker.isHidden = true
        addChild(marker)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // 터치 위치를 Scene 좌표로 변환
        let location = touch.location(in: self)
        
        print("터치 위치: (\(location.x), \(location.y))")
        
        // 마커를 터치 위치로 이동
        if let marker = childNode(withName: "marker") {
            marker.position = location
            marker.isHidden = false
        }
        
        // 이전 터치 위치 (드래그 방향 계산에 유용)
        let previousLocation = touch.previousLocation(in: self)
        print("이전 위치: (\(previousLocation.x), \(previousLocation.y))")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let marker = childNode(withName: "marker") {
            marker.position = location
        }
    }
}
