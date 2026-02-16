import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // Scene 크기 조정 모드 (ScaleMode)
        
        // .fill: Scene을 View에 맞춰 늘림 (비율 무시)
        // .aspectFill: 비율 유지, View를 채움 (일부 잘릴 수 있음)
        // .aspectFit: 비율 유지, Scene 전체가 보임 (레터박스 가능)
        // .resizeFill: Scene 크기를 View 크기에 맞춤
        
        // 일반적으로 aspectFill 권장
        self.scaleMode = .aspectFill
        
        backgroundColor = .black
        
        // 기준 Scene 크기 설정 (디자인 기준)
        // 예: iPhone 8 기준 (375 x 667)
        // Scene 생성 시: GameScene(size: CGSize(width: 375, height: 667))
        
        setupGame()
    }
    
    func setupGame() {
        // Scene 크기 기준으로 요소 배치
        // frame.midX, frame.midY는 Scene 크기 기준
        
        let player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: 100)
        addChild(player)
    }
}
