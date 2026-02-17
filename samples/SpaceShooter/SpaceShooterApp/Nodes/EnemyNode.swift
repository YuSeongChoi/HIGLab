// EnemyNode.swift
// SpaceShooter - SpriteKit 2D 게임
// 적 우주선 노드

import SpriteKit

/// 적 유형
enum EnemyType: CaseIterable {
    /// 기본 적 (직선 이동)
    case basic
    
    /// 빠른 적 (지그재그 이동)
    case fast
    
    /// 강한 적 (높은 체력, 느림)
    case heavy
    
    /// 보스 적 (매우 높은 체력, 총알 발사)
    case boss
    
    /// 기본 체력
    var baseHealth: Int {
        switch self {
        case .basic: return 1
        case .fast: return 1
        case .heavy: return 3
        case .boss: return 10
        }
    }
    
    /// 기본 속도
    var baseSpeed: CGFloat {
        switch self {
        case .basic: return 100
        case .fast: return 180
        case .heavy: return 60
        case .boss: return 40
        }
    }
    
    /// 크기 배율
    var sizeScale: CGFloat {
        switch self {
        case .basic: return 1.0
        case .fast: return 0.8
        case .heavy: return 1.5
        case .boss: return 2.5
        }
    }
    
    /// 점수 값
    var scoreValue: Int {
        switch self {
        case .basic: return EnemyScore.basic.rawValue
        case .fast: return EnemyScore.fast.rawValue
        case .heavy: return EnemyScore.heavy.rawValue
        case .boss: return EnemyScore.boss.rawValue
        }
    }
    
    /// 외형 색상
    var color: UIColor {
        switch self {
        case .basic: return UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        case .fast: return UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        case .heavy: return UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)
        case .boss: return UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        }
    }
    
    /// 폭발 색상
    var explosionColor: UIColor {
        switch self {
        case .basic: return .orange
        case .fast: return .yellow
        case .heavy: return .purple
        case .boss: return .red
        }
    }
}

/// 적 우주선 노드
final class EnemyNode: SKNode {
    // MARK: - 프로퍼티
    
    /// 적 유형
    let type: EnemyType
    
    /// 현재 체력
    private(set) var health: Int
    
    /// 최대 체력
    let maxHealth: Int
    
    /// 이동 속도
    let speed: CGFloat
    
    /// 점수 값
    var scoreValue: Int { type.scoreValue }
    
    /// 폭발 색상
    var explosionColor: UIColor { type.explosionColor }
    
    /// 본체 노드
    private var bodyNode: SKShapeNode!
    
    /// 체력바 배경
    private var healthBarBackground: SKShapeNode?
    
    /// 체력바
    private var healthBar: SKShapeNode?
    
    /// 이동 패턴용 시간
    private var movementTime: TimeInterval = 0
    
    // MARK: - 초기화
    
    /// 적 노드 초기화
    /// - Parameters:
    ///   - type: 적 유형
    ///   - difficulty: 난이도 레벨
    init(type: EnemyType, difficulty: DifficultyLevel = .normal) {
        self.type = type
        self.maxHealth = type.baseHealth * difficulty.enemyHealthMultiplier
        self.health = self.maxHealth
        self.speed = type.baseSpeed * difficulty.enemySpeedMultiplier
        
        super.init()
        
        setupBody()
        setupPhysics()
        
        // 체력이 1 초과면 체력바 표시
        if maxHealth > 1 {
            setupHealthBar()
        }
        
        // 이동 패턴 시작
        startMovementPattern()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 설정
    
    /// 본체 설정
    private func setupBody() {
        let scale = type.sizeScale
        
        // 적 우주선 모양 (아래를 향한 삼각형)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -20 * scale))     // 하단 꼭지점
        path.addLine(to: CGPoint(x: -15 * scale, y: 15 * scale)) // 좌상단
        path.addLine(to: CGPoint(x: 0, y: 8 * scale))    // 상단 중앙
        path.addLine(to: CGPoint(x: 15 * scale, y: 15 * scale))  // 우상단
        path.close()
        
        bodyNode = SKShapeNode(path: path.cgPath)
        bodyNode.fillColor = type.color
        bodyNode.strokeColor = type.color.withAlphaComponent(0.5)
        bodyNode.lineWidth = 2
        bodyNode.glowWidth = type == .boss ? 5 : 2
        
        addChild(bodyNode)
        
        // 적 눈 (위협적인 느낌)
        addEyes(scale: scale)
        
        // 보스는 추가 장식
        if type == .boss {
            addBossDecorations(scale: scale)
        }
    }
    
    /// 눈 추가
    private func addEyes(scale: CGFloat) {
        let eyeSize: CGFloat = 3 * scale
        let eyeY: CGFloat = 0
        let eyeSpacing: CGFloat = 6 * scale
        
        // 좌측 눈
        let leftEye = SKShapeNode(circleOfRadius: eyeSize)
        leftEye.position = CGPoint(x: -eyeSpacing, y: eyeY)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.glowWidth = 2
        addChild(leftEye)
        
        // 우측 눈
        let rightEye = SKShapeNode(circleOfRadius: eyeSize)
        rightEye.position = CGPoint(x: eyeSpacing, y: eyeY)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.glowWidth = 2
        addChild(rightEye)
    }
    
    /// 보스 전용 장식 추가
    private func addBossDecorations(scale: CGFloat) {
        // 좌측 날개
        let leftWing = SKShapeNode()
        let leftPath = UIBezierPath()
        leftPath.move(to: CGPoint(x: -15 * scale, y: 10 * scale))
        leftPath.addLine(to: CGPoint(x: -35 * scale, y: 5 * scale))
        leftPath.addLine(to: CGPoint(x: -20 * scale, y: -5 * scale))
        leftPath.close()
        leftWing.path = leftPath.cgPath
        leftWing.fillColor = type.color.withAlphaComponent(0.7)
        leftWing.strokeColor = type.color
        leftWing.lineWidth = 2
        addChild(leftWing)
        
        // 우측 날개
        let rightWing = SKShapeNode()
        let rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(x: 15 * scale, y: 10 * scale))
        rightPath.addLine(to: CGPoint(x: 35 * scale, y: 5 * scale))
        rightPath.addLine(to: CGPoint(x: 20 * scale, y: -5 * scale))
        rightPath.close()
        rightWing.path = rightPath.cgPath
        rightWing.fillColor = type.color.withAlphaComponent(0.7)
        rightWing.strokeColor = type.color
        rightWing.lineWidth = 2
        addChild(rightWing)
    }
    
    /// 물리 바디 설정
    private func setupPhysics() {
        let radius = 15 * type.sizeScale
        let body = SKPhysicsBody(circleOfRadius: radius)
        
        body.categoryBitMask = PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.enemyContacts
        body.collisionBitMask = PhysicsCategory.none
        
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        physicsBody = body
    }
    
    /// 체력바 설정
    private func setupHealthBar() {
        let barWidth: CGFloat = 30 * type.sizeScale
        let barHeight: CGFloat = 4
        let barY: CGFloat = 20 * type.sizeScale
        
        // 배경
        let background = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        background.position = CGPoint(x: 0, y: barY)
        background.fillColor = UIColor.darkGray
        background.strokeColor = .clear
        background.zPosition = 10
        addChild(background)
        healthBarBackground = background
        
        // 체력바
        let bar = SKShapeNode(rectOf: CGSize(width: barWidth - 2, height: barHeight - 2), cornerRadius: 1)
        bar.position = CGPoint(x: 0, y: barY)
        bar.fillColor = .green
        bar.strokeColor = .clear
        bar.zPosition = 11
        addChild(bar)
        healthBar = bar
    }
    
    /// 체력바 업데이트
    private func updateHealthBar() {
        guard let bar = healthBar else { return }
        
        let healthRatio = CGFloat(health) / CGFloat(maxHealth)
        let barWidth: CGFloat = (30 * type.sizeScale - 2) * healthRatio
        
        // 크기 업데이트
        bar.xScale = healthRatio
        
        // 색상 업데이트
        if healthRatio > 0.6 {
            bar.fillColor = .green
        } else if healthRatio > 0.3 {
            bar.fillColor = .yellow
        } else {
            bar.fillColor = .red
        }
    }
    
    // MARK: - 이동 패턴
    
    /// 이동 패턴 시작
    private func startMovementPattern() {
        switch type {
        case .basic:
            // 직선 이동
            let moveDown = SKAction.moveBy(x: 0, y: -speed, duration: 1.0)
            run(SKAction.repeatForever(moveDown))
            
        case .fast:
            // 지그재그 이동
            startZigzagMovement()
            
        case .heavy:
            // 느린 직선 이동 + 좌우 흔들림
            startSwayingMovement()
            
        case .boss:
            // 복합 이동 패턴
            startBossMovement()
        }
    }
    
    /// 지그재그 이동 (빠른 적)
    private func startZigzagMovement() {
        let zigzagWidth: CGFloat = 80
        let zigzagDuration: TimeInterval = 0.8
        
        // 아래로 이동하면서 좌우로 지그재그
        let moveDownAction = SKAction.moveBy(x: 0, y: -speed * 0.8, duration: 1.0)
        run(SKAction.repeatForever(moveDownAction))
        
        // 좌우 지그재그
        let moveRight = SKAction.moveBy(x: zigzagWidth, y: 0, duration: zigzagDuration)
        let moveLeft = SKAction.moveBy(x: -zigzagWidth, y: 0, duration: zigzagDuration)
        moveRight.timingMode = .easeInEaseOut
        moveLeft.timingMode = .easeInEaseOut
        
        let zigzag = SKAction.sequence([moveRight, moveLeft])
        run(SKAction.repeatForever(zigzag))
    }
    
    /// 흔들림 이동 (강한 적)
    private func startSwayingMovement() {
        // 느린 하강
        let moveDown = SKAction.moveBy(x: 0, y: -speed, duration: 1.0)
        run(SKAction.repeatForever(moveDown))
        
        // 좌우 천천히 흔들림
        let swayAmount: CGFloat = 30
        let swayRight = SKAction.moveBy(x: swayAmount, y: 0, duration: 1.5)
        let swayLeft = SKAction.moveBy(x: -swayAmount, y: 0, duration: 1.5)
        swayRight.timingMode = .easeInEaseOut
        swayLeft.timingMode = .easeInEaseOut
        
        let sway = SKAction.sequence([swayRight, swayLeft])
        run(SKAction.repeatForever(sway))
    }
    
    /// 보스 이동 패턴
    private func startBossMovement() {
        // 화면 상단에서 좌우로 이동
        let moveRight = SKAction.moveBy(x: 100, y: 0, duration: 2.0)
        let moveLeft = SKAction.moveBy(x: -100, y: 0, duration: 2.0)
        moveRight.timingMode = .easeInEaseOut
        moveLeft.timingMode = .easeInEaseOut
        
        let pattern = SKAction.sequence([moveRight, moveLeft])
        run(SKAction.repeatForever(pattern))
        
        // 천천히 하강
        let slowDescent = SKAction.moveBy(x: 0, y: -20, duration: 3.0)
        run(SKAction.repeatForever(slowDescent))
    }
    
    // MARK: - 데미지 처리
    
    /// 데미지 받기
    /// - Parameter damage: 데미지 양
    /// - Returns: 사망 여부
    @discardableResult
    func takeDamage(_ damage: Int) -> Bool {
        health -= damage
        
        // 피격 이펙트
        flashWhite()
        
        // 체력바 업데이트
        updateHealthBar()
        
        return health <= 0
    }
    
    /// 흰색 플래시 효과
    private func flashWhite() {
        let originalColor = bodyNode.fillColor
        
        let flashAction = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.bodyNode.fillColor = .white
            },
            SKAction.wait(forDuration: 0.05),
            SKAction.run { [weak self] in
                self?.bodyNode.fillColor = originalColor
            }
        ])
        
        run(flashAction)
    }
}
