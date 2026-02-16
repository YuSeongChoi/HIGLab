import SpriteKit

class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        let titleLabel = SKLabelNode(text: "내 게임")
        titleLabel.fontSize = 48
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(titleLabel)
        
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
        
        if nodes(at: location).contains(where: { $0.name == "startButton" }) {
            transitionToGame()
        }
    }
    
    func transitionToGame() {
        // 게임 씬 생성
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        
        // 전환 효과 생성
        let transition = SKTransition.crossFade(withDuration: 1.0)
        // 다른 전환 효과들:
        // let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        // let transition = SKTransition.push(with: .left, duration: 0.5)
        // let transition = SKTransition.doorway(withDuration: 1.0)
        // let transition = SKTransition.reveal(with: .down, duration: 0.5)
        
        // 전환 실행
        view?.presentScene(gameScene, transition: transition)
    }
}
