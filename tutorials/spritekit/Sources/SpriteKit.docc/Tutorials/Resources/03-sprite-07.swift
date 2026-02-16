import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 텍스처 아틀라스 로드
        // Assets에 "Characters.spriteatlas" 폴더가 있어야 합니다
        let atlas = SKTextureAtlas(named: "Characters")
        
        // 아틀라스에서 텍스처 가져오기
        let playerTexture = atlas.textureNamed("player_idle")
        let enemyTexture = atlas.textureNamed("enemy_idle")
        
        // 스프라이트 생성
        let player = SKSpriteNode(texture: playerTexture)
        player.position = CGPoint(x: frame.midX - 50, y: frame.midY)
        addChild(player)
        
        let enemy = SKSpriteNode(texture: enemyTexture)
        enemy.position = CGPoint(x: frame.midX + 50, y: frame.midY)
        addChild(enemy)
        
        // 아틀라스 프리로드 (비동기)
        SKTextureAtlas.preloadTextureAtlases([atlas]) {
            print("텍스처 아틀라스 로드 완료!")
        }
    }
}
