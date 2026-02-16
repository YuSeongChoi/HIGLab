import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        // 플레이어
        let player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: 100)
        player.name = "player"
        addChild(player)
        
        // 적들
        for i in 0..<3 {
            let enemy = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
            enemy.position = CGPoint(x: 100 + i * 100, y: 300)
            enemy.name = "enemy"
            addChild(enemy)
        }
        
        // 코인들
        for i in 0..<4 {
            let coin = SKSpriteNode(color: .yellow, size: CGSize(width: 25, height: 25))
            coin.position = CGPoint(x: 80 + i * 80, y: 200)
            coin.name = "coin"
            addChild(coin)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            switch node.name {
            case "player":
                print("플레이어 선택!")
                highlightNode(node)
                
            case "enemy":
                print("적 터치! 공격!")
                destroyNode(node)
                
            case "coin":
                print("코인 수집!")
                collectCoin(node)
                
            default:
                break
            }
        }
    }
    
    func highlightNode(_ node: SKNode) {
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        node.run(pulse)
    }
    
    func destroyNode(_ node: SKNode) {
        let destroy = SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.2),
            SKAction.removeFromParent()
        ])
        node.run(destroy)
    }
    
    func collectCoin(_ node: SKNode) {
        let collect = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.1)
            ]),
            SKAction.removeFromParent()
        ])
        node.run(collect)
    }
}
