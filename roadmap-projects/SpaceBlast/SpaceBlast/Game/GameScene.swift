import SpriteKit
import CoreHaptics

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    var scoreCallback: ((Int) -> Void)?
    var gameOverCallback: (() -> Void)?
    
    private var player: SKSpriteNode!
    private var score = 0
    private var hapticEngine: CHHapticEngine?
    
    // Physics categories
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let player: UInt32 = 0b1
        static let bullet: UInt32 = 0b10
        static let enemy: UInt32 = 0b100
    }
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupHaptics()
        startSpawningEnemies()
    }
    
    // MARK: - Setup
    private func setupScene() {
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // 배경 별 파티클
        if let stars = SKEmitterNode(fileNamed: "StarField") {
            stars.position = CGPoint(x: size.width / 2, y: size.height)
            stars.advanceSimulationTime(10)
            stars.zPosition = -1
            addChild(stars)
        }
    }
    
    private func setupPlayer() {
        player = SKSpriteNode(color: .cyan, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: size.width / 2, y: 100)
        player.name = "player"
        
        // 우주선 모양
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 25))
        path.addLine(to: CGPoint(x: -25, y: -25))
        path.addLine(to: CGPoint(x: 25, y: -25))
        path.close()
        
        let shape = SKShapeNode(path: path.cgPath)
        shape.fillColor = .cyan
        shape.strokeColor = .white
        shape.lineWidth = 2
        player.addChild(shape)
        player.color = .clear
        
        // Physics
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.isDynamic = true
        
        addChild(player)
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }
    
    // MARK: - Enemy Spawning
    private func startSpawningEnemies() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let delay = SKAction.wait(forDuration: 1.0, withRange: 0.5)
        let sequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(sequence))
    }
    
    private func spawnEnemy() {
        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        let randomX = CGFloat.random(in: 50...(size.width - 50))
        enemy.position = CGPoint(x: randomX, y: size.height + 50)
        enemy.name = "enemy"
        
        // Physics
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.none
        enemy.physicsBody?.isDynamic = true
        
        addChild(enemy)
        
        // Move down
        let moveDown = SKAction.moveTo(y: -50, duration: 4.0)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveDown, remove]))
    }
    
    // MARK: - Shooting
    private func shoot() {
        let bullet = SKSpriteNode(color: .yellow, size: CGSize(width: 5, height: 15))
        bullet.position = CGPoint(x: player.position.x, y: player.position.y + 30)
        bullet.name = "bullet"
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
        bullet.physicsBody?.isDynamic = true
        
        addChild(bullet)
        
        let moveUp = SKAction.moveTo(y: size.height + 20, duration: 0.5)
        let remove = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveUp, remove]))
        
        playShootHaptic()
    }
    
    // MARK: - Haptics
    private func playShootHaptic() {
        guard let engine = hapticEngine else { return }
        
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    private func playExplosionHaptic() {
        guard let engine = hapticEngine else { return }
        
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 0.2)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shoot()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position.x = max(30, min(size.width - 30, location.x))
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyA : contact.bodyB
        let secondBody = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyB : contact.bodyA
        
        // Bullet hits enemy
        if firstBody.categoryBitMask == PhysicsCategory.bullet && secondBody.categoryBitMask == PhysicsCategory.enemy {
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            
            score += 10
            scoreCallback?(score)
            playExplosionHaptic()
            
            // Explosion effect
            if let pos = secondBody.node?.position {
                createExplosion(at: pos)
            }
        }
        
        // Player hits enemy
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.enemy {
            playExplosionHaptic()
            gameOverCallback?()
        }
    }
    
    private func createExplosion(at position: CGPoint) {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleBirthRate = 100
        explosion.numParticlesToEmit = 20
        explosion.particleLifetime = 0.5
        explosion.particleSpeed = 100
        explosion.particleSpeedRange = 50
        explosion.emissionAngleRange = .pi * 2
        explosion.particleScale = 0.3
        explosion.particleScaleRange = 0.2
        explosion.particleColor = .orange
        explosion.particleColorBlendFactor = 1.0
        explosion.position = position
        
        addChild(explosion)
        
        let wait = SKAction.wait(forDuration: 0.5)
        let remove = SKAction.removeFromParent()
        explosion.run(SKAction.sequence([wait, remove]))
    }
}
