import SwiftUI
import SpriteKit

struct GameView: View {
    @Binding var score: Int
    @Binding var isPlaying: Bool
    
    var scene: GameScene {
        let scene = GameScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        scene.scoreCallback = { newScore in
            score = newScore
        }
        scene.gameOverCallback = {
            isPlaying = false
        }
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    GameView(score: .constant(0), isPlaying: .constant(true))
}
