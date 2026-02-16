import SpriteKit

class GameScene: SKScene {
    var initialDistance: CGFloat?
    var initialScale: CGFloat = 1.0
    var zoomTarget: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        // 줌 대상
        zoomTarget = SKSpriteNode(color: .cyan, size: CGSize(width: 100, height: 100))
        zoomTarget.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(zoomTarget)
        
        let label = SKLabelNode(text: "두 손가락으로 핀치!")
        label.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        label.fontSize = 20
        addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let allTouches = event?.allTouches, allTouches.count == 2 else { return }
        
        let touchArray = Array(allTouches)
        let pos1 = touchArray[0].location(in: self)
        let pos2 = touchArray[1].location(in: self)
        
        // 두 터치 사이의 초기 거리 저장
        initialDistance = hypot(pos2.x - pos1.x, pos2.y - pos1.y)
        initialScale = zoomTarget.xScale
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let allTouches = event?.allTouches, allTouches.count == 2,
              let initialDist = initialDistance else { return }
        
        let touchArray = Array(allTouches)
        let pos1 = touchArray[0].location(in: self)
        let pos2 = touchArray[1].location(in: self)
        
        // 현재 거리
        let currentDistance = hypot(pos2.x - pos1.x, pos2.y - pos1.y)
        
        // 스케일 계산
        let scale = (currentDistance / initialDist) * initialScale
        
        // 최소/최대 스케일 제한
        let clampedScale = max(0.5, min(3.0, scale))
        
        zoomTarget.setScale(clampedScale)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        initialDistance = nil
    }
}
