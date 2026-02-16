import SpriteKit

class GameScene: SKScene {
    var player: SKSpriteNode?
    var lastUpdateTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPlayer()
    }
    
    func setupPlayer() {
        player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player?.position = CGPoint(x: frame.midX, y: 100)
        if let player = player {
            addChild(player)
        }
    }
    
    // 매 프레임마다 호출 (약 60fps)
    override func update(_ currentTime: TimeInterval) {
        // 델타 타임 계산
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // 게임 로직 업데이트
        updateGameLogic(deltaTime: deltaTime)
    }
    
    func updateGameLogic(deltaTime: TimeInterval) {
        // 플레이어 위치 업데이트
        // 적 AI 처리
        // 충돌 체크 등
    }
    
    // 액션 평가 후 호출
    override func didEvaluateActions() {
        // 액션이 적용된 후 추가 처리
    }
    
    // 물리 시뮬레이션 후 호출
    override func didSimulatePhysics() {
        // 물리 적용 후 위치 보정 등
    }
}
