import SpriteKit

class GameScene: SKScene {
    var player: SKSpriteNode!
    var walkFrames: [SKTexture] = []
    
    override func didMove(to view: SKView) {
        setupPlayer()
        playWalkAnimation()
    }
    
    func setupPlayer() {
        let atlas = SKTextureAtlas(named: "Characters")
        
        // 걷기 애니메이션 프레임 로드
        for i in 1...4 {
            walkFrames.append(atlas.textureNamed("player_walk_\(i)"))
        }
        
        // 첫 프레임으로 플레이어 생성
        player = SKSpriteNode(texture: walkFrames[0])
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(player)
    }
    
    func playWalkAnimation() {
        // 스프라이트 시트 애니메이션 생성
        let animateAction = SKAction.animate(
            with: walkFrames,
            timePerFrame: 0.1,           // 각 프레임 0.1초
            resize: false,                // 크기 유지
            restore: true                 // 완료 후 원래 텍스처로 복원
        )
        
        // 무한 반복
        let repeatAction = SKAction.repeatForever(animateAction)
        
        // 키와 함께 실행 (나중에 중지할 수 있도록)
        player.run(repeatAction, withKey: "walkAnimation")
    }
    
    func stopWalkAnimation() {
        player.removeAction(forKey: "walkAnimation")
    }
}
