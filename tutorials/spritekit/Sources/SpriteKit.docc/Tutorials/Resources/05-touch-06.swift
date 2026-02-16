import SpriteKit

class GameScene: SKScene {
    var playButton: SKSpriteNode!
    var settingsButton: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        setupButtons()
    }
    
    func setupButtons() {
        // 플레이 버튼
        playButton = createButton(text: "Play", color: .green)
        playButton.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        playButton.name = "playButton"
        addChild(playButton)
        
        // 설정 버튼
        settingsButton = createButton(text: "Settings", color: .blue)
        settingsButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        settingsButton.name = "settingsButton"
        addChild(settingsButton)
    }
    
    func createButton(text: String, color: UIColor) -> SKSpriteNode {
        let button = SKSpriteNode(color: color, size: CGSize(width: 200, height: 60))
        
        let label = SKLabelNode(text: text)
        label.fontColor = .white
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let button = node as? SKSpriteNode, button.name?.contains("Button") == true {
                // 눌린 효과
                button.run(SKAction.scale(to: 0.9, duration: 0.1))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let button = node as? SKSpriteNode {
                // 원래 크기로 복구
                button.run(SKAction.scale(to: 1.0, duration: 0.1))
                
                // 버튼 액션 실행
                switch button.name {
                case "playButton":
                    print("게임 시작!")
                case "settingsButton":
                    print("설정 열기!")
                default:
                    break
                }
            }
        }
    }
}
