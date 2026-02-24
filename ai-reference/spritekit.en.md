# SpriteKit AI Reference

> 2D game development guide. You can generate SpriteKit code by reading this document.

## Overview

SpriteKit is Apple's 2D game engine.
It supports sprite rendering, physics simulation, particle effects, and animation.

## Required Import

```swift
import SpriteKit
import SwiftUI  // For SwiftUI integration
```

## Core Components

### 1. SKScene (Game Scene)

```swift
class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // Called when scene is displayed
        setupGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called every frame (game loop)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches
    }
}
```

### 2. SKSpriteNode (Sprite)

```swift
// Create from image
let player = SKSpriteNode(imageNamed: "player")
player.position = CGPoint(x: 100, y: 100)
player.size = CGSize(width: 50, height: 50)
addChild(player)

// Create from color
let enemy = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
addChild(enemy)
```

### 3. SKAction (Animation)

```swift
// Move
let moveAction = SKAction.move(to: CGPoint(x: 300, y: 300), duration: 1.0)

// Rotate
let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 1.0)

// Scale
let scaleAction = SKAction.scale(to: 2.0, duration: 0.5)

// Sequence
let sequence = SKAction.sequence([moveAction, scaleAction])

// Group (simultaneous)
let group = SKAction.group([moveAction, rotateAction])

// Repeat
let repeatForever = SKAction.repeatForever(rotateAction)

// Run
player.run(sequence)
```

## Complete Working Example

```swift
import SpriteKit
import SwiftUI

// MARK: - Game Scene
class SpaceShooterScene: SKScene, SKPhysicsContactDelegate {
    // Node references
    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    
    // Game state
    private var score = 0
    private var isGameOver = false
    
    // Physics categories
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
        
        // Star background
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
        
        // Physics body
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
        
        // Move then remove
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
        // Explosion effect
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = position
            addChild(explosion)
            
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait, remove]))
        }
        
        // Increase score
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
        
        // Bullet + Enemy
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
        
        // Player + Enemy
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

## Advanced Patterns

### 1. Sprite Animation

```swift
func setupPlayerAnimation() {
    let textures = (1...4).map { SKTexture(imageNamed: "player_\($0)") }
    let animation = SKAction.animate(with: textures, timePerFrame: 0.1)
    player.run(SKAction.repeatForever(animation))
}
```

### 2. Tilemap

```swift
func setupTileMap() {
    guard let tileSet = SKTileSet(named: "GameTiles") else { return }
    
    let tileMap = SKTileMapNode(
        tileSet: tileSet,
        columns: 20,
        rows: 20,
        tileSize: CGSize(width: 32, height: 32)
    )
    
    // Place tiles
    if let grassTile = tileSet.tileGroups.first(where: { $0.name == "Grass" }) {
        tileMap.fill(with: grassTile)
    }
    
    addChild(tileMap)
}
```

### 3. Camera

```swift
func setupCamera() {
    let camera = SKCameraNode()
    camera.position = player.position
    self.camera = camera
    addChild(camera)
}

override func update(_ currentTime: TimeInterval) {
    // Camera follows player
    camera?.position = player.position
}
```

### 4. Sound

```swift
// Sound effect
let soundAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
run(soundAction)

// Background music
let bgMusic = SKAudioNode(fileNamed: "background.mp3")
bgMusic.autoplayLooped = true
addChild(bgMusic)
```

## Notes

1. **Performance Optimization**
   - Use `SKTexture` atlases
   - Remove nodes outside screen
   - Simplify `physicsBody`

2. **Coordinate System**
   - Origin is bottom-left (different from UIKit)
   - Default `anchorPoint` is (0.5, 0.5)

3. **Scene Transition**
   ```swift
   let transition = SKTransition.fade(withDuration: 1.0)
   view?.presentScene(newScene, transition: transition)
   ```

4. **SwiftUI Integration**
   - Use `SpriteView(scene:)`
   - Supports `isPaused`, `debugOptions`
