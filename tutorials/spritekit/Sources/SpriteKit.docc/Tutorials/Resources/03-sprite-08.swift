import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let atlas = SKTextureAtlas(named: "Characters")
        
        // 걷기 애니메이션 프레임 추출
        // 이미지 이름: player_walk_1, player_walk_2, player_walk_3, player_walk_4
        var walkFrames: [SKTexture] = []
        
        for i in 1...4 {
            let textureName = "player_walk_\(i)"
            let texture = atlas.textureNamed(textureName)
            walkFrames.append(texture)
        }
        
        // 또는 아틀라스의 모든 텍스처 이름 가져오기
        let textureNames = atlas.textureNames.sorted()
        print("아틀라스 내 텍스처들: \(textureNames)")
        
        // 필터링하여 특정 애니메이션 프레임만 추출
        let runFrames = textureNames
            .filter { $0.hasPrefix("player_run_") }
            .map { atlas.textureNamed($0) }
        
        print("달리기 프레임 수: \(runFrames.count)")
    }
}
