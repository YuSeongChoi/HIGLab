// GameScene.swift
// SpaceShooter - SpriteKit 2D 게임
// 메인 게임 씬

import SpriteKit
import Combine

/// 메인 게임 씬
/// SpriteKit의 SKScene을 상속하여 게임 로직을 구현합니다.
final class GameScene: SKScene {
    // MARK: - 게임 상태 참조
    
    /// 공유 게임 상태 (SwiftUI와 연동)
    weak var gameState: GameState?
    
    // MARK: - 게임 노드
    
    /// 플레이어 우주선
    private var player: PlayerNode?
    
    /// 적 스포너
    private var enemySpawner: EnemySpawner?
    
    // MARK: - 레이어 노드
    
    /// 배경 레이어
    private let backgroundLayer = SKNode()
    
    /// 게임 오브젝트 레이어
    private let gameLayer = SKNode()
    
    /// 이펙트 레이어
    private let effectLayer = SKNode()
    
    /// UI 레이어
    private let uiLayer = SKNode()
    
    // MARK: - 배경 별
    
    /// 배경 별 이미터 노드
    private var starEmitter: SKEmitterNode?
    
    // MARK: - 타이밍
    
    /// 마지막 업데이트 시간
    private var lastUpdateTime: TimeInterval = 0
    
    /// 자동 발사 타이머
    private var lastFireTime: TimeInterval = 0
    
    /// 발사 간격 (초)
    private let fireInterval: TimeInterval = 0.2
    
    // MARK: - 터치 추적
    
    /// 현재 터치 위치 (nil이면 터치 없음)
    private var touchLocation: CGPoint?
    
    // MARK: - Combine 구독
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 씬 라이프사이클
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        setupScene()
        setupLayers()
        setupBackground()
        setupPhysics()
        setupPlayer()
        setupSpawner()
        bindGameState()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        cancellables.removeAll()
    }
    
    // MARK: - 초기 설정
    
    /// 씬 기본 설정
    private func setupScene() {
        backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.1, alpha: 1.0)
    }
    
    /// 레이어 계층 구조 설정
    private func setupLayers() {
        // Z 순서에 따라 레이어 추가
        backgroundLayer.zPosition = -100
        gameLayer.zPosition = 0
        effectLayer.zPosition = 100
        uiLayer.zPosition = 200
        
        addChild(backgroundLayer)
        addChild(gameLayer)
        addChild(effectLayer)
        addChild(uiLayer)
    }
    
    /// 배경 설정 (별 파티클)
    private func setupBackground() {
        // 별 파티클 이펙트 생성
        let starEmitter = createStarEmitter()
        starEmitter.position = CGPoint(x: size.width / 2, y: size.height)
        starEmitter.zPosition = -50
        backgroundLayer.addChild(starEmitter)
        self.starEmitter = starEmitter
        
        // 추가 배경 별 (정적)
        createStaticStars(count: 50)
    }
    
    /// 별 이미터 생성
    private func createStarEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // 기본 설정
        emitter.particleBirthRate = 20
        emitter.particleLifetime = 10
        emitter.particleLifetimeRange = 2
        
        // 위치 및 이동
        emitter.position = CGPoint(x: size.width / 2, y: size.height + 10)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 40
        emitter.emissionAngle = .pi * 1.5 // 아래 방향
        
        // 크기
        emitter.particleSize = CGSize(width: 2, height: 2)
        emitter.particleScaleRange = 1.0
        
        // 색상
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.3
        
        // 블렌드 모드
        emitter.particleBlendMode = .add
        
        return emitter
    }
    
    /// 정적 배경 별 생성
    private func createStaticStars(count: Int) {
        for _ in 0..<count {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...0.8)
            star.zPosition = -60
            
            // 깜빡임 애니메이션
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1...3))
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 1...3))
            let sequence = SKAction.sequence([fadeOut, fadeIn])
            star.run(SKAction.repeatForever(sequence))
            
            backgroundLayer.addChild(star)
        }
    }
    
    /// 물리 엔진 설정
    private func setupPhysics() {
        // 물리 월드 설정
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // 화면 경계 설정 (총알이 화면 밖으로 나가면 제거)
        let boundary = SKPhysicsBody(edgeLoopFrom: frame.insetBy(dx: -50, dy: -50))
        boundary.categoryBitMask = PhysicsCategory.boundary
        physicsBody = boundary
    }
    
    /// 플레이어 설정
    private func setupPlayer() {
        let player = PlayerNode()
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        gameLayer.addChild(player)
        self.player = player
    }
    
    /// 적 스포너 설정
    private func setupSpawner() {
        enemySpawner = EnemySpawner(scene: self, gameLayer: gameLayer)
    }
    
    /// 게임 상태 바인딩
    private func bindGameState() {
        gameState?.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleStatusChange(status)
            }
            .store(in: &cancellables)
    }
    
    /// 게임 상태 변경 처리
    private func handleStatusChange(_ status: GameStatus) {
        switch status {
        case .ready:
            resetScene()
            isPaused = true
            
        case .playing:
            if isPaused {
                isPaused = false
            }
            enemySpawner?.startSpawning()
            
        case .paused:
            isPaused = true
            enemySpawner?.stopSpawning()
            
        case .gameOver:
            isPaused = true
            enemySpawner?.stopSpawning()
        }
    }
    
    /// 씬 리셋 (새 게임 시작 시)
    private func resetScene() {
        // 모든 적과 총알 제거
        gameLayer.children.forEach { node in
            if node is EnemyNode || node is BulletNode {
                node.removeFromParent()
            }
        }
        
        // 이펙트 제거
        effectLayer.removeAllChildren()
        
        // 플레이어 위치 리셋
        player?.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        player?.reset()
        
        // 타이밍 리셋
        lastUpdateTime = 0
        lastFireTime = 0
        touchLocation = nil
        
        // 점수 매니저 리셋
        ScoreManager.shared.resetAll()
    }
    
    // MARK: - 게임 루프
    
    override func update(_ currentTime: TimeInterval) {
        // 델타 타임 계산
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard gameState?.status == .playing else { return }
        
        // 게임 시간 업데이트
        gameState?.updatePlayTime(deltaTime)
        
        // 플레이어 이동 처리
        updatePlayerMovement()
        
        // 자동 발사
        if currentTime - lastFireTime >= fireInterval {
            firePlayerBullet()
            lastFireTime = currentTime
        }
        
        // 화면 밖 오브젝트 정리
        cleanupOffscreenNodes()
        
        // 적 스포너 업데이트
        if let difficulty = gameState?.difficulty {
            enemySpawner?.update(deltaTime: deltaTime, difficulty: difficulty)
        }
    }
    
    /// 플레이어 이동 업데이트
    private func updatePlayerMovement() {
        guard let player = player, let touch = touchLocation else { return }
        
        // 터치 위치로 부드럽게 이동
        let moveSpeed: CGFloat = 0.15
        let newX = player.position.x + (touch.x - player.position.x) * moveSpeed
        let newY = player.position.y + (touch.y - player.position.y) * moveSpeed
        
        // 화면 경계 내로 제한
        let margin: CGFloat = 30
        let clampedX = max(margin, min(size.width - margin, newX))
        let clampedY = max(margin, min(size.height * 0.6, newY)) // 상단 40%는 적 영역
        
        player.position = CGPoint(x: clampedX, y: clampedY)
    }
    
    /// 플레이어 총알 발사
    private func firePlayerBullet() {
        guard let player = player else { return }
        
        let bullet = BulletNode(isPlayerBullet: true)
        bullet.position = CGPoint(x: player.position.x, y: player.position.y + 30)
        gameLayer.addChild(bullet)
        
        // 위쪽으로 발사
        let velocity = CGVector(dx: 0, dy: 500)
        bullet.physicsBody?.velocity = velocity
    }
    
    /// 화면 밖 노드 정리
    private func cleanupOffscreenNodes() {
        let margin: CGFloat = 100
        let cleanupRect = frame.insetBy(dx: -margin, dy: -margin)
        
        gameLayer.children.forEach { node in
            if !cleanupRect.contains(node.position) {
                if node is BulletNode || node is EnemyNode {
                    node.removeFromParent()
                }
            }
        }
    }
    
    // MARK: - 터치 처리
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchLocation = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchLocation = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
    
    // MARK: - 폭발 이펙트
    
    /// 폭발 파티클 생성
    /// - Parameters:
    ///   - position: 폭발 위치
    ///   - color: 폭발 색상
    ///   - scale: 폭발 크기 배율
    func createExplosion(at position: CGPoint, color: UIColor = .orange, scale: CGFloat = 1.0) {
        let explosion = createExplosionEmitter(color: color, scale: scale)
        explosion.position = position
        effectLayer.addChild(explosion)
        
        // 일정 시간 후 제거
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        explosion.run(SKAction.sequence([wait, remove]))
    }
    
    /// 폭발 이미터 생성
    private func createExplosionEmitter(color: UIColor, scale: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // 기본 설정
        emitter.particleBirthRate = 200
        emitter.numParticlesToEmit = 30
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.3
        
        // 이동
        emitter.particleSpeed = 150 * scale
        emitter.particleSpeedRange = 100 * scale
        emitter.emissionAngleRange = .pi * 2
        
        // 크기
        emitter.particleSize = CGSize(width: 8 * scale, height: 8 * scale)
        emitter.particleScaleSpeed = -2
        
        // 색상
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -2
        
        // 블렌드
        emitter.particleBlendMode = .add
        
        return emitter
    }
    
    // MARK: - 데미지 처리
    
    /// 플레이어 피격 처리
    func playerHit() {
        guard let player = player else { return }
        
        // 폭발 이펙트
        createExplosion(at: player.position, color: .red, scale: 0.8)
        
        // 화면 흔들림
        shakeScreen()
        
        // 플레이어 깜빡임 (무적 시간)
        player.startInvincibility()
        
        // 콤보 리셋
        ScoreManager.shared.resetCombo()
        
        // 게임 상태 업데이트
        gameState?.playerHit()
    }
    
    /// 화면 흔들림 효과
    private func shakeScreen() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 20, y: 0, duration: 0.05),
            SKAction.moveBy(x: -20, y: 0, duration: 0.05),
            SKAction.moveBy(x: 20, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05)
        ])
        
        gameLayer.run(shake)
    }
    
    /// 적 처치 처리
    /// - Parameters:
    ///   - enemy: 처치된 적
    ///   - position: 처치 위치
    func enemyDefeated(_ enemy: EnemyNode, at position: CGPoint) {
        // 폭발 이펙트
        createExplosion(at: position, color: enemy.explosionColor, scale: 1.2)
        
        // 점수 계산 및 추가
        let currentTime = lastUpdateTime
        let wave = gameState?.wave ?? 1
        let score = ScoreManager.shared.calculateScore(
            baseScore: enemy.scoreValue,
            currentTime: currentTime,
            wave: wave
        )
        
        gameState?.addScore(score)
        gameState?.enemyDefeated()
        
        // 점수 팝업 표시
        showScorePopup(score: score, at: position)
    }
    
    /// 점수 팝업 표시
    private func showScorePopup(score: Int, at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "+\(score)"
        label.fontSize = 18
        label.fontColor = .yellow
        label.position = position
        label.zPosition = 150
        uiLayer.addChild(label)
        
        // 콤보 표시
        let combo = ScoreManager.shared.currentCombo
        if combo > 1 {
            let comboLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            comboLabel.text = "x\(combo)"
            comboLabel.fontSize = 14
            comboLabel.fontColor = .cyan
            comboLabel.position = CGPoint(x: position.x, y: position.y - 20)
            comboLabel.zPosition = 150
            uiLayer.addChild(comboLabel)
            
            let comboFade = SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: 0, y: 30, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5)
                ]),
                SKAction.removeFromParent()
            ])
            comboLabel.run(comboFade)
        }
        
        // 애니메이션
        let fadeUp = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6)
            ]),
            SKAction.removeFromParent()
        ])
        label.run(fadeUp)
    }
}

// MARK: - 물리 충돌 처리

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // 두 물체 정렬 (카테고리 비트마스크 순서대로)
        let (firstBody, secondBody) = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
            ? (contact.bodyA, contact.bodyB)
            : (contact.bodyB, contact.bodyA)
        
        // 플레이어 총알 vs 적
        if firstBody.categoryBitMask == PhysicsCategory.playerBullet &&
           secondBody.categoryBitMask == PhysicsCategory.enemy {
            handlePlayerBulletHitEnemy(bullet: firstBody.node, enemy: secondBody.node)
        }
        
        // 플레이어 vs 적
        else if firstBody.categoryBitMask == PhysicsCategory.player &&
                secondBody.categoryBitMask == PhysicsCategory.enemy {
            handlePlayerHitEnemy(player: firstBody.node, enemy: secondBody.node)
        }
        
        // 플레이어 vs 적 총알
        else if firstBody.categoryBitMask == PhysicsCategory.player &&
                secondBody.categoryBitMask == PhysicsCategory.enemyBullet {
            handlePlayerHitByBullet(player: firstBody.node, bullet: secondBody.node)
        }
    }
    
    /// 플레이어 총알이 적에게 명중
    private func handlePlayerBulletHitEnemy(bullet: SKNode?, enemy: SKNode?) {
        guard let bullet = bullet as? BulletNode,
              let enemy = enemy as? EnemyNode else { return }
        
        let hitPosition = bullet.position
        bullet.removeFromParent()
        
        // 적에게 데미지
        let isDead = enemy.takeDamage(1)
        
        if isDead {
            enemyDefeated(enemy, at: hitPosition)
            enemy.removeFromParent()
        } else {
            // 피격 이펙트만
            let spark = createSparkEffect()
            spark.position = hitPosition
            effectLayer.addChild(spark)
        }
    }
    
    /// 플레이어와 적 충돌
    private func handlePlayerHitEnemy(player: SKNode?, enemy: SKNode?) {
        guard let playerNode = player as? PlayerNode,
              let enemyNode = enemy as? EnemyNode else { return }
        
        // 무적 상태면 무시
        guard !playerNode.isInvincible else { return }
        
        let position = enemyNode.position
        
        // 적 제거
        enemyDefeated(enemyNode, at: position)
        enemyNode.removeFromParent()
        
        // 플레이어 피격
        playerHit()
    }
    
    /// 플레이어가 적 총알에 피격
    private func handlePlayerHitByBullet(player: SKNode?, bullet: SKNode?) {
        guard let playerNode = player as? PlayerNode,
              let bulletNode = bullet as? BulletNode else { return }
        
        // 무적 상태면 무시
        guard !playerNode.isInvincible else { return }
        
        bulletNode.removeFromParent()
        playerHit()
    }
    
    /// 스파크 이펙트 생성
    private func createSparkEffect() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 10
        emitter.particleLifetime = 0.2
        emitter.particleSpeed = 100
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSize = CGSize(width: 4, height: 4)
        emitter.particleColor = .white
        emitter.particleBlendMode = .add
        
        // 자동 제거
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        return emitter
    }
}
