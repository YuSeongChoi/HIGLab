import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // zPosition으로 렌더링 순서 제어
        // 값이 클수록 앞에(위에) 그려집니다
        
        // 배경 (가장 뒤)
        let background = SKSpriteNode(color: .darkGray, size: self.size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -10  // 음수 = 뒤쪽
        addChild(background)
        
        // 중간 레이어
        let midLayer = SKSpriteNode(color: .blue, size: CGSize(width: 200, height: 200))
        midLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        midLayer.zPosition = 0  // 기본값
        addChild(midLayer)
        
        // 앞쪽 레이어
        let frontLayer = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        frontLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        frontLayer.zPosition = 10  // 양수 = 앞쪽
        addChild(frontLayer)
        
        // UI는 가장 앞에
        let uiElement = SKLabelNode(text: "UI")
        uiElement.position = CGPoint(x: frame.midX, y: frame.midY)
        uiElement.zPosition = 100
        addChild(uiElement)
    }
}
