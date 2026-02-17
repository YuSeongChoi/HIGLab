// BulletNode.swift
// SpaceShooter - SpriteKit 2D 게임
// 총알 노드

import SpriteKit

/// 총알 노드
/// 플레이어와 적 모두 사용합니다.
final class BulletNode: SKNode {
    // MARK: - 프로퍼티
    
    /// 플레이어 총알 여부
    let isPlayerBullet: Bool
    
    /// 데미지 값
    let damage: Int
    
    /// 총알 본체
    private var bulletBody: SKShapeNode!
    
    /// 트레일 이펙트
    private var trailEmitter: SKEmitterNode?
    
    // MARK: - 초기화
    
    /// 총알 노드 초기화
    /// - Parameters:
    ///   - isPlayerBullet: 플레이어 총알 여부
    ///   - damage: 데미지 값 (기본값: 1)
    init(isPlayerBullet: Bool, damage: Int = 1) {
        self.isPlayerBullet = isPlayerBullet
        self.damage = damage
        
        super.init()
        
        setupBullet()
        setupPhysics()
        setupTrail()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 설정
    
    /// 총알 외형 설정
    private func setupBullet() {
        if isPlayerBullet {
            setupPlayerBullet()
        } else {
            setupEnemyBullet()
        }
    }
    
    /// 플레이어 총알 외형
    private func setupPlayerBullet() {
        // 긴 타원형 총알
        let bulletPath = UIBezierPath(ovalIn: CGRect(x: -3, y: -8, width: 6, height: 16))
        
        bulletBody = SKShapeNode(path: bulletPath.cgPath)
        bulletBody.fillColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
        bulletBody.strokeColor = .white
        bulletBody.lineWidth = 1
        bulletBody.glowWidth = 4
        
        addChild(bulletBody)
        
        // 중심 밝은 부분
        let core = SKShapeNode(circleOfRadius: 2)
        core.fillColor = .white
        core.strokeColor = .clear
        core.glowWidth = 3
        addChild(core)
    }
    
    /// 적 총알 외형
    private func setupEnemyBullet() {
        // 원형 총알
        bulletBody = SKShapeNode(circleOfRadius: 5)
        bulletBody.fillColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        bulletBody.strokeColor = .yellow
        bulletBody.lineWidth = 1
        bulletBody.glowWidth = 3
        
        addChild(bulletBody)
        
        // 내부 밝은 부분
        let core = SKShapeNode(circleOfRadius: 2)
        core.fillColor = .white
        core.strokeColor = .clear
        addChild(core)
    }
    
    /// 물리 바디 설정
    private func setupPhysics() {
        let radius: CGFloat = isPlayerBullet ? 3 : 5
        let body = SKPhysicsBody(circleOfRadius: radius)
        
        if isPlayerBullet {
            body.categoryBitMask = PhysicsCategory.playerBullet
            body.contactTestBitMask = PhysicsCategory.playerBulletContacts
        } else {
            body.categoryBitMask = PhysicsCategory.enemyBullet
            body.contactTestBitMask = PhysicsCategory.enemyBulletContacts
        }
        
        body.collisionBitMask = PhysicsCategory.none
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        physicsBody = body
    }
    
    /// 트레일 이펙트 설정
    private func setupTrail() {
        let trail = createTrailEmitter()
        trail.zPosition = -1
        addChild(trail)
        trailEmitter = trail
    }
    
    /// 트레일 이미터 생성
    private func createTrailEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // 기본 설정
        emitter.particleBirthRate = 80
        emitter.particleLifetime = 0.2
        emitter.particleLifetimeRange = 0.1
        
        // 크기
        emitter.particleSize = CGSize(width: 4, height: 4)
        emitter.particleScaleSpeed = -3
        
        // 색상
        if isPlayerBullet {
            emitter.particleColor = .cyan
        } else {
            emitter.particleColor = .red
        }
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.6
        emitter.particleAlphaSpeed = -3
        
        // 블렌드
        emitter.particleBlendMode = .add
        
        // 위치 (살짝 뒤쪽)
        if isPlayerBullet {
            emitter.position = CGPoint(x: 0, y: -5)
        } else {
            emitter.position = CGPoint(x: 0, y: 5)
        }
        
        return emitter
    }
}

// MARK: - 총알 팩토리

/// 총알 생성을 위한 팩토리 메서드
extension BulletNode {
    /// 플레이어 기본 총알 생성
    static func playerBullet() -> BulletNode {
        return BulletNode(isPlayerBullet: true, damage: 1)
    }
    
    /// 플레이어 강화 총알 생성 (파워업 시)
    static func playerPowerBullet() -> BulletNode {
        let bullet = BulletNode(isPlayerBullet: true, damage: 2)
        bullet.xScale = 1.5
        bullet.yScale = 1.5
        return bullet
    }
    
    /// 적 기본 총알 생성
    static func enemyBullet() -> BulletNode {
        return BulletNode(isPlayerBullet: false, damage: 1)
    }
    
    /// 보스 총알 생성 (더 큼)
    static func bossBullet() -> BulletNode {
        let bullet = BulletNode(isPlayerBullet: false, damage: 1)
        bullet.xScale = 1.8
        bullet.yScale = 1.8
        return bullet
    }
}

// MARK: - 총알 패턴

/// 다양한 총알 발사 패턴
struct BulletPattern {
    /// 직선 발사
    /// - Parameters:
    ///   - from: 발사 위치
    ///   - direction: 방향 (단위 벡터)
    ///   - speed: 속도
    ///   - isPlayer: 플레이어 총알 여부
    /// - Returns: 설정된 총알 노드
    static func straight(
        from position: CGPoint,
        direction: CGVector,
        speed: CGFloat,
        isPlayer: Bool
    ) -> BulletNode {
        let bullet = isPlayer ? BulletNode.playerBullet() : BulletNode.enemyBullet()
        bullet.position = position
        
        // 방향 정규화
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        let normalizedDirection = CGVector(
            dx: direction.dx / length * speed,
            dy: direction.dy / length * speed
        )
        
        bullet.physicsBody?.velocity = normalizedDirection
        
        return bullet
    }
    
    /// 부채꼴 발사 (여러 총알)
    /// - Parameters:
    ///   - from: 발사 위치
    ///   - count: 총알 수
    ///   - spreadAngle: 펼침 각도 (라디안)
    ///   - speed: 속도
    ///   - isPlayer: 플레이어 총알 여부
    /// - Returns: 설정된 총알 노드 배열
    static func spread(
        from position: CGPoint,
        count: Int,
        spreadAngle: CGFloat,
        speed: CGFloat,
        isPlayer: Bool
    ) -> [BulletNode] {
        var bullets: [BulletNode] = []
        
        // 기본 방향 (위 또는 아래)
        let baseAngle: CGFloat = isPlayer ? .pi / 2 : -.pi / 2
        let angleStep = count > 1 ? spreadAngle / CGFloat(count - 1) : 0
        let startAngle = baseAngle - spreadAngle / 2
        
        for i in 0..<count {
            let angle = startAngle + angleStep * CGFloat(i)
            let direction = CGVector(dx: cos(angle), dy: sin(angle))
            
            let bullet = straight(from: position, direction: direction, speed: speed, isPlayer: isPlayer)
            bullets.append(bullet)
        }
        
        return bullets
    }
    
    /// 원형 발사 (모든 방향)
    /// - Parameters:
    ///   - from: 발사 위치
    ///   - count: 총알 수
    ///   - speed: 속도
    ///   - isPlayer: 플레이어 총알 여부
    /// - Returns: 설정된 총알 노드 배열
    static func circular(
        from position: CGPoint,
        count: Int,
        speed: CGFloat,
        isPlayer: Bool
    ) -> [BulletNode] {
        var bullets: [BulletNode] = []
        
        let angleStep = .pi * 2 / CGFloat(count)
        
        for i in 0..<count {
            let angle = angleStep * CGFloat(i)
            let direction = CGVector(dx: cos(angle), dy: sin(angle))
            
            let bullet = straight(from: position, direction: direction, speed: speed, isPlayer: isPlayer)
            bullets.append(bullet)
        }
        
        return bullets
    }
}
