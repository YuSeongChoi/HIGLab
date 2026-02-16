import SpriteKit

class GameScene: SKScene {
    var player: SKSpriteNode?
    var score: Int = 0
    
    override func didMove(to view: SKView) {
        // Scene이 View에 표시될 때 호출
        // 초기 설정을 수행하기 좋은 위치
        
        // 배경색 설정
        backgroundColor = .black
        
        // 플레이어 생성
        setupPlayer()
        
        // UI 설정
        setupUI()
        
        // 게임 시작
        startGame()
    }
    
    func setupPlayer() {
        player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player?.position = CGPoint(x: frame.midX, y: 100)
        if let player = player {
            addChild(player)
        }
    }
    
    func setupUI() {
        let scoreLabel = SKLabelNode(text: "점수: 0")
        scoreLabel.name = "scoreLabel"
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(scoreLabel)
    }
    
    func startGame() {
        print("게임 시작!")
    }
}
