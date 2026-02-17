// PlayerNode.swift
// SpaceShooter - SpriteKit 2D 게임
// 플레이어 우주선 노드

import SpriteKit

/// 플레이어 우주선 노드
/// 터치 입력에 따라 이동하며 자동으로 총알을 발사합니다.
final class PlayerNode: SKNode {
    // MARK: - 프로퍼티
    
    /// 우주선 본체 (시각적 요소)
    private var shipBody: SKShapeNode!
    
    /// 엔진 불꽃 이펙트
    private var engineFlame: SKEmitterNode?
    
    /// 무적 상태 여부
    private(set) var isInvincible: Bool = false
    
    /// 무적 지속 시간 (초)
    private let invincibilityDuration: TimeInterval = 2.0
    
    /// 쉴드 노드 (무적 시 표시)
    private var shield: SKShapeNode?
    
    // MARK: - 초기화
    
    override init() {
        super.init()
        setupShip()
        setupPhysics()
        setupEngineFlame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShip()
        setupPhysics()
        setupEngineFlame()
    }
    
    // MARK: - 설정
    
    /// 우주선 외형 설정
    private func setupShip() {
        // 우주선 본체 (삼각형 모양)
        let shipPath = UIBezierPath()
        shipPath.move(to: CGPoint(x: 0, y: 25))      // 상단 꼭지점
        shipPath.addLine(to: CGPoint(x: -20, y: -20)) // 좌하단
        shipPath.addLine(to: CGPoint(x: 0, y: -10))   // 하단 중앙
        shipPath.addLine(to: CGPoint(x: 20, y: -20))  // 우하단
        shipPath.close()
        
        shipBody = SKShapeNode(path: shipPath.cgPath)
        shipBody.fillColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        shipBody.strokeColor = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
        shipBody.lineWidth = 2
        shipBody.glowWidth = 3
        
        addChild(shipBody)
        
        // 조종석 (작은 원)
        let cockpit = SKShapeNode(circleOfRadius: 5)
        cockpit.fillColor = .cyan
        cockpit.strokeColor = .white
        cockpit.lineWidth = 1
        cockpit.position = CGPoint(x: 0, y: 5)
        cockpit.glowWidth = 2
        
        addChild(cockpit)
        
        // 날개 하이라이트
        addWingHighlights()
    }
    
    /// 날개 하이라이트 추가
    private func addWingHighlights() {
        // 좌측 날개
        let leftWing = SKShapeNode()
        let leftPath = UIBezierPath()
        leftPath.move(to: CGPoint(x: -5, y: 0))
        leftPath.addLine(to: CGPoint(x: -18, y: -15))
        leftPath.addLine(to: CGPoint(x: -8, y: -10))
        leftPath.close()
        leftWing.path = leftPath.cgPath
        leftWing.fillColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.5)
        leftWing.strokeColor = .clear
        addChild(leftWing)
        
        // 우측 날개
        let rightWing = SKShapeNode()
        let rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(x: 5, y: 0))
        rightPath.addLine(to: CGPoint(x: 18, y: -15))
        rightPath.addLine(to: CGPoint(x: 8, y: -10))
        rightPath.close()
        rightWing.path = rightPath.cgPath
        rightWing.fillColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.5)
        rightWing.strokeColor = .clear
        addChild(rightWing)
    }
    
    /// 물리 바디 설정
    private func setupPhysics() {
        // 충돌 영역 (원형으로 간소화)
        let body = SKPhysicsBody(circleOfRadius: 15)
        
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.playerContacts
        body.collisionBitMask = PhysicsCategory.none
        
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        physicsBody = body
    }
    
    /// 엔진 불꽃 이펙트 설정
    private func setupEngineFlame() {
        let flame = createFlameEmitter()
        flame.position = CGPoint(x: 0, y: -15)
        flame.zPosition = -1
        addChild(flame)
        self.engineFlame = flame
    }
    
    /// 불꽃 이미터 생성
    private func createFlameEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // 기본 설정
        emitter.particleBirthRate = 100
        emitter.particleLifetime = 0.3
        emitter.particleLifetimeRange = 0.1
        
        // 이동 (아래쪽으로)
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = .pi * 1.5 // 아래 방향
        emitter.emissionAngleRange = 0.3
        
        // 크기
        emitter.particleSize = CGSize(width: 10, height: 15)
        emitter.particleScaleSpeed = -2
        
        // 색상 (주황 → 노랑)
        emitter.particleColor = .orange
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = nil
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -2
        
        // 블렌드
        emitter.particleBlendMode = .add
        
        return emitter
    }
    
    // MARK: - 무적 시스템
    
    /// 무적 상태 시작
    func startInvincibility() {
        guard !isInvincible else { return }
        
        isInvincible = true
        
        // 쉴드 이펙트 생성
        createShieldEffect()
        
        // 깜빡임 애니메이션
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        shipBody.run(SKAction.repeat(blink, count: Int(invincibilityDuration / 0.2)), withKey: "blink")
        
        // 무적 종료 예약
        let wait = SKAction.wait(forDuration: invincibilityDuration)
        let endInvincibility = SKAction.run { [weak self] in
            self?.endInvincibility()
        }
        run(SKAction.sequence([wait, endInvincibility]), withKey: "invincibility")
    }
    
    /// 무적 상태 종료
    private func endInvincibility() {
        isInvincible = false
        
        // 깜빡임 중지
        shipBody.removeAction(forKey: "blink")
        shipBody.alpha = 1.0
        
        // 쉴드 제거
        removeShieldEffect()
    }
    
    /// 쉴드 이펙트 생성
    private func createShieldEffect() {
        let shield = SKShapeNode(circleOfRadius: 30)
        shield.strokeColor = .cyan
        shield.fillColor = UIColor.cyan.withAlphaComponent(0.1)
        shield.lineWidth = 2
        shield.glowWidth = 5
        shield.zPosition = 10
        
        // 펄스 애니메이션
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        shield.run(SKAction.repeatForever(pulse))
        
        addChild(shield)
        self.shield = shield
    }
    
    /// 쉴드 이펙트 제거
    private func removeShieldEffect() {
        shield?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        shield = nil
    }
    
    // MARK: - 상태 관리
    
    /// 플레이어 리셋 (새 게임 시작 시)
    func reset() {
        // 무적 상태 해제
        isInvincible = false
        removeAction(forKey: "invincibility")
        shipBody.removeAction(forKey: "blink")
        shipBody.alpha = 1.0
        removeShieldEffect()
        
        // 엔진 불꽃 재시작
        engineFlame?.resetSimulation()
    }
    
    // MARK: - 이동 효과
    
    /// 이동 방향에 따른 기울기 효과
    /// - Parameter direction: 이동 방향 (-1: 좌, 0: 정면, 1: 우)
    func updateTilt(direction: CGFloat) {
        let maxTilt: CGFloat = 0.3 // 최대 기울기 (라디안)
        let targetRotation = -direction * maxTilt
        
        let rotate = SKAction.rotate(toAngle: targetRotation, duration: 0.1)
        shipBody.run(rotate)
    }
}
