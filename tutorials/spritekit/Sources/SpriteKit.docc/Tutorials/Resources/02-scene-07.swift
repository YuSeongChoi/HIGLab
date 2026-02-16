import SpriteKit

class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        // 타이틀
        let titleLabel = SKLabelNode(text: "내 게임")
        titleLabel.fontSize = 48
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(titleLabel)
        
        // 시작 버튼
        let startButton = SKLabelNode(text: "게임 시작")
        startButton.name = "startButton"
        startButton.fontSize = 32
        startButton.fontColor = .yellow
        startButton.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(startButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "startButton" {
                // 게임 씬으로 전환
                transitionToGame()
            }
        }
    }
    
    func transitionToGame() {
        // 다음 Section에서 구현
    }
}
