# SpriteKit AI Reference

> 2D 게임 개발 가이드. 이 문서를 읽고 SpriteKit 코드를 생성할 수 있습니다.

## 개요

SpriteKit은 Apple의 2D 게임 엔진입니다.
스프라이트 렌더링, 물리 시뮬레이션, 파티클 효과, 애니메이션을 지원합니다.

## 필수 Import

```swift
import SpriteKit
import SwiftUI  // SwiftUI 통합 시
```

## 핵심 구성요소

### 1. SKScene (게임 씬)

```swift
class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // 씬이 표시될 때 호출
        setupGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 매 프레임 호출 (게임 루프)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 터치 처리
    }
}
```

### 2. SKSpriteNode (스프라이트)

```swift
// 이미지로 생성
let player = SKSpriteNode(imageNamed: "player")
player.position = CGPoint(x: 100, y: 100)
player.size = CGSize(width: 50, height: 50)
addChild(player)

// 색상으로 생성
let enemy = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
addChild(enemy)
```

### 3. SKAction (애니메이션)

```swift
// 이동
let moveAction = SKAction.move(to: CGPoint(x: 300, y: 300), duration: 1.0)

// 회전
let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 1.0)

// 크기 변경
let scaleAction = SKAction.scale(to: 2.0, duration: 0.5)

// 순차 실행
let sequence = SKAction.sequence([moveAction, scaleAction])

// 동시 실행
let group = SKAction.group([moveAction, rotateAction])

// 반복
let repeatForever = SKAction.repeatForever(rotateAction)

// 실행
player.run(sequence)
```

## 전체 작동 예제

```swift
import SpriteKit
import SwiftUI

// MARK: - Game Scene
class SpaceShooterScene: SKScene, SKPhysicsContactDelegate {
    // 노드 참조
    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    
    // 게임 상태
    private var score = 0
    private var isGameOver = false
    
    // 물리 카테고리
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let player: UInt32 = 0b1
        static let enemy: UInt32 = 0b10
        static let bullet: UInt32 = 0b100
    }
    
    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupUI()
        startSpawning()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }
    
    // MARK: - Setup
    private func setupScene() {
        backgroundColor = .black
        
        // 별 배경
        if let stars = SKEmitterNode(fileNamed: "Stars") {
            stars.position = CGPoint(x: size.width / 2, y: size.height)
            stars.zPosition = -1
            addChild(stars)
        }
    }
    
    private func setupPlayer() {
        player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: size.width / 2, y: 100)
        player.name = "player"
        
        // 물리 바디
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.isDynamic = true
        
        addChild(player)
    }
    
    private func setupUI() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
    }
    
    // MARK: - Game Logic
    private func startSpawning() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let waitAction = SKAction.wait(forDuration: 1.0, withRange: 0.5)
        let sequence = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(sequence))
    }
    
    private func spawnEnemy() {
        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        let randomX = CGFloat.random(in: 50...(size.width - 50))
        enemy.position = CGPoint(x: randomX, y: size.height + 50)
        enemy.name = "enemy"
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(enemy)
        
        // 이동 후 제거
        let moveAction = SKAction.moveTo(y: -50, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    private func fireBullet() {
        let bullet = SKSpriteNode(color: .yellow, size: CGSize(width: 5, height: 20))
        bullet.position = CGPoint(x: player.position.x, y: player.position.y + 30)
        bullet.name = "bullet"
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
        bullet.physicsBody?.isDynamic = true
        
        addChild(bullet)
        
        let moveAction = SKAction.moveTo(y: size.height + 50, duration: 0.5)
        let removeAction = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    private func enemyDestroyed(at position: CGPoint) {
        // 폭발 효과
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = position
            addChild(explosion)
            
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait, remove]))
        }
        
        // 점수 증가
        score += 10
        scoreLabel.text = "Score: \(score)"
    }
    
    private func gameOver() {
        isGameOver = true
        removeAllActions()
        
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 48
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        fireBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isGameOver else { return }
        
        let location = touch.location(in: self)
        player.position.x = location.x
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // 총알 + 적
        if (bodyA.categoryBitMask == PhysicsCategory.bullet && bodyB.categoryBitMask == PhysicsCategory.enemy) ||
           (bodyA.categoryBitMask == PhysicsCategory.enemy && bodyB.categoryBitMask == PhysicsCategory.bullet) {
            
            let enemyNode = bodyA.categoryBitMask == PhysicsCategory.enemy ? bodyA.node : bodyB.node
            let bulletNode = bodyA.categoryBitMask == PhysicsCategory.bullet ? bodyA.node : bodyB.node
            
            if let position = enemyNode?.position {
                enemyDestroyed(at: position)
            }
            
            enemyNode?.removeFromParent()
            bulletNode?.removeFromParent()
        }
        
        // 플레이어 + 적
        if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.enemy) ||
           (bodyA.categoryBitMask == PhysicsCategory.enemy && bodyB.categoryBitMask == PhysicsCategory.player) {
            gameOver()
        }
    }
}

// MARK: - SwiftUI Integration
struct GameView: View {
    var body: some View {
        SpriteView(scene: makeScene())
            .ignoresSafeArea()
    }
    
    func makeScene() -> SKScene {
        let scene = SpaceShooterScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        return scene
    }
}
```

## 고급 패턴

### 1. 스프라이트 애니메이션

```swift
func setupPlayerAnimation() {
    let textures = (1...4).map { SKTexture(imageNamed: "player_\($0)") }
    let animation = SKAction.animate(with: textures, timePerFrame: 0.1)
    player.run(SKAction.repeatForever(animation))
}
```

### 2. 타일맵

```swift
func setupTileMap() {
    guard let tileSet = SKTileSet(named: "GameTiles") else { return }
    
    let tileMap = SKTileMapNode(
        tileSet: tileSet,
        columns: 20,
        rows: 20,
        tileSize: CGSize(width: 32, height: 32)
    )
    
    // 타일 배치
    if let grassTile = tileSet.tileGroups.first(where: { $0.name == "Grass" }) {
        tileMap.fill(with: grassTile)
    }
    
    addChild(tileMap)
}
```

### 3. 카메라

```swift
func setupCamera() {
    let camera = SKCameraNode()
    camera.position = player.position
    self.camera = camera
    addChild(camera)
}

override func update(_ currentTime: TimeInterval) {
    // 카메라가 플레이어 따라가기
    camera?.position = player.position
}
```

### 4. 사운드

```swift
// 효과음
let soundAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
run(soundAction)

// 배경음악
let bgMusic = SKAudioNode(fileNamed: "background.mp3")
bgMusic.autoplayLooped = true
addChild(bgMusic)
```

## 주의사항

1. **성능 최적화**
   - `SKTexture` 아틀라스 사용
   - 화면 밖 노드 제거
   - `physicsBody` 단순화

2. **좌표계**
   - 원점이 좌하단 (UIKit과 다름)
   - `anchorPoint` 기본값 (0.5, 0.5)

3. **씬 전환**
   ```swift
   let transition = SKTransition.fade(withDuration: 1.0)
   view?.presentScene(newScene, transition: transition)
   ```

4. **SwiftUI 통합**
   - `SpriteView(scene:)` 사용
   - `isPaused`, `debugOptions` 지원
