// EnemySpawner.swift
// SpaceShooter - SpriteKit 2D 게임
// 적 스폰 시스템

import SpriteKit

/// 적 스폰을 관리하는 클래스
/// 난이도에 따라 적절한 간격과 유형으로 적을 생성합니다.
final class EnemySpawner {
    // MARK: - 프로퍼티
    
    /// 게임 씬 참조
    private weak var scene: GameScene?
    
    /// 게임 오브젝트 레이어
    private weak var gameLayer: SKNode?
    
    /// 스폰 활성화 여부
    private var isSpawning: Bool = false
    
    /// 마지막 스폰 시간
    private var lastSpawnTime: TimeInterval = 0
    
    /// 현재 스폰 간격
    private var currentSpawnInterval: TimeInterval = 2.0
    
    /// 누적 시간
    private var accumulatedTime: TimeInterval = 0
    
    /// 스폰된 적 수 (웨이브 내)
    private var enemiesSpawnedInWave: Int = 0
    
    /// 보스 스폰 여부
    private var bossSpawned: Bool = false
    
    // MARK: - 스폰 설정
    
    /// 적 유형별 스폰 가중치 (기본)
    private var spawnWeights: [EnemyType: Int] = [
        .basic: 60,
        .fast: 25,
        .heavy: 15,
        .boss: 0
    ]
    
    /// 웨이브당 적 수
    private let enemiesPerWave: Int = 10
    
    /// 보스 등장 웨이브 간격
    private let bossWaveInterval: Int = 5
    
    // MARK: - 초기화
    
    /// 스포너 초기화
    /// - Parameters:
    ///   - scene: 게임 씬
    ///   - gameLayer: 적을 추가할 레이어
    init(scene: GameScene, gameLayer: SKNode) {
        self.scene = scene
        self.gameLayer = gameLayer
    }
    
    // MARK: - 스폰 제어
    
    /// 스폰 시작
    func startSpawning() {
        isSpawning = true
        accumulatedTime = 0
        lastSpawnTime = 0
    }
    
    /// 스폰 중지
    func stopSpawning() {
        isSpawning = false
    }
    
    /// 웨이브 리셋
    func resetWave() {
        enemiesSpawnedInWave = 0
        bossSpawned = false
    }
    
    // MARK: - 업데이트
    
    /// 매 프레임 업데이트
    /// - Parameters:
    ///   - deltaTime: 이전 프레임 이후 경과 시간
    ///   - difficulty: 현재 난이도
    func update(deltaTime: TimeInterval, difficulty: DifficultyLevel) {
        guard isSpawning else { return }
        
        accumulatedTime += deltaTime
        currentSpawnInterval = difficulty.spawnInterval
        
        // 스폰 간격 체크
        if accumulatedTime - lastSpawnTime >= currentSpawnInterval {
            spawnEnemy(difficulty: difficulty)
            lastSpawnTime = accumulatedTime
        }
    }
    
    // MARK: - 스폰 로직
    
    /// 적 스폰
    private func spawnEnemy(difficulty: DifficultyLevel) {
        guard let scene = scene, let gameLayer = gameLayer else { return }
        
        // 적 유형 결정
        let enemyType = selectEnemyType(difficulty: difficulty)
        
        // 적 생성
        let enemy = EnemyNode(type: enemyType, difficulty: difficulty)
        
        // 스폰 위치 결정
        let spawnPosition = calculateSpawnPosition(for: enemyType, sceneSize: scene.size)
        enemy.position = spawnPosition
        
        // 레이어에 추가
        gameLayer.addChild(enemy)
        
        // 스폰 카운트 증가
        enemiesSpawnedInWave += 1
        
        // 보스면 특수 처리
        if enemyType == .boss {
            bossSpawned = true
            setupBossBehavior(enemy)
        }
    }
    
    /// 적 유형 선택 (가중치 기반)
    private func selectEnemyType(difficulty: DifficultyLevel) -> EnemyType {
        // 보스 체크 (웨이브 5, 10, 15... 마다)
        if let gameState = scene?.gameState,
           gameState.wave % bossWaveInterval == 0 && !bossSpawned {
            return .boss
        }
        
        // 난이도에 따른 가중치 조정
        var weights = spawnWeights
        
        switch difficulty {
        case .easy:
            weights[.basic] = 80
            weights[.fast] = 15
            weights[.heavy] = 5
            
        case .normal:
            weights[.basic] = 60
            weights[.fast] = 25
            weights[.heavy] = 15
            
        case .hard:
            weights[.basic] = 40
            weights[.fast] = 35
            weights[.heavy] = 25
            
        case .insane:
            weights[.basic] = 30
            weights[.fast] = 40
            weights[.heavy] = 30
        }
        
        // 가중치 기반 랜덤 선택
        return weightedRandomSelect(weights: weights)
    }
    
    /// 가중치 기반 랜덤 선택
    private func weightedRandomSelect(weights: [EnemyType: Int]) -> EnemyType {
        let totalWeight = weights.values.reduce(0, +)
        var random = Int.random(in: 0..<totalWeight)
        
        for (type, weight) in weights {
            random -= weight
            if random < 0 {
                return type
            }
        }
        
        return .basic
    }
    
    /// 스폰 위치 계산
    private func calculateSpawnPosition(for type: EnemyType, sceneSize: CGSize) -> CGPoint {
        let margin: CGFloat = 50
        
        switch type {
        case .basic, .fast:
            // 화면 상단 랜덤 위치
            let x = CGFloat.random(in: margin...(sceneSize.width - margin))
            let y = sceneSize.height + 30
            return CGPoint(x: x, y: y)
            
        case .heavy:
            // 화면 상단 중앙 부근
            let centerX = sceneSize.width / 2
            let x = CGFloat.random(in: (centerX - 100)...(centerX + 100))
            let y = sceneSize.height + 40
            return CGPoint(x: x, y: y)
            
        case .boss:
            // 화면 상단 중앙
            let x = sceneSize.width / 2
            let y = sceneSize.height - 100
            return CGPoint(x: x, y: y)
        }
    }
    
    /// 보스 특수 행동 설정
    private func setupBossBehavior(_ boss: EnemyNode) {
        guard let scene = scene, let gameLayer = gameLayer else { return }
        
        // 등장 연출
        let scaleIn = SKAction.sequence([
            SKAction.scale(to: 0.1, duration: 0),
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        boss.run(scaleIn)
        
        // 주기적 총알 발사
        let fireAction = SKAction.run { [weak self, weak boss, weak gameLayer] in
            guard let self = self,
                  let boss = boss,
                  let gameLayer = gameLayer,
                  boss.parent != nil else { return }
            
            self.bossFirePattern(from: boss.position, to: gameLayer)
        }
        
        let fireSequence = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            fireAction
        ])
        
        boss.run(SKAction.repeatForever(fireSequence), withKey: "bossFire")
    }
    
    /// 보스 총알 패턴
    private func bossFirePattern(from position: CGPoint, to layer: SKNode) {
        // 부채꼴 패턴
        let bullets = BulletPattern.spread(
            from: position,
            count: 5,
            spreadAngle: .pi / 3,
            speed: 200,
            isPlayer: false
        )
        
        for bullet in bullets {
            layer.addChild(bullet)
        }
    }
}

// MARK: - 웨이브 관리 확장

extension EnemySpawner {
    /// 현재 웨이브에 맞는 적 구성 반환
    func getWaveComposition(wave: Int) -> [EnemyType: Int] {
        var composition: [EnemyType: Int] = [:]
        
        // 기본 웨이브 구성
        let baseEnemies = enemiesPerWave + (wave - 1) * 2
        
        switch wave {
        case 1...3:
            // 초반: 기본 적 위주
            composition[.basic] = baseEnemies
            
        case 4...6:
            // 중반: 빠른 적 추가
            composition[.basic] = Int(Double(baseEnemies) * 0.6)
            composition[.fast] = Int(Double(baseEnemies) * 0.4)
            
        case 7...9:
            // 후반: 강한 적 추가
            composition[.basic] = Int(Double(baseEnemies) * 0.4)
            composition[.fast] = Int(Double(baseEnemies) * 0.3)
            composition[.heavy] = Int(Double(baseEnemies) * 0.3)
            
        default:
            // 10웨이브 이후: 모든 유형 혼합
            composition[.basic] = Int(Double(baseEnemies) * 0.3)
            composition[.fast] = Int(Double(baseEnemies) * 0.35)
            composition[.heavy] = Int(Double(baseEnemies) * 0.35)
        }
        
        // 5웨이브마다 보스 추가
        if wave % bossWaveInterval == 0 {
            composition[.boss] = 1
        }
        
        return composition
    }
    
    /// 다음 웨이브 준비
    func prepareNextWave(wave: Int) {
        enemiesSpawnedInWave = 0
        bossSpawned = false
        
        // 웨이브에 따른 스폰 간격 조정
        let baseInterval: TimeInterval = 2.0
        let reduction = Double(wave - 1) * 0.1
        currentSpawnInterval = max(0.5, baseInterval - reduction)
    }
}

// MARK: - 디버그 유틸리티

#if DEBUG
extension EnemySpawner {
    /// 특정 유형의 적 즉시 스폰 (디버깅용)
    func debugSpawn(type: EnemyType, at position: CGPoint? = nil) {
        guard let scene = scene, let gameLayer = gameLayer else { return }
        
        let enemy = EnemyNode(type: type, difficulty: .normal)
        
        if let pos = position {
            enemy.position = pos
        } else {
            enemy.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 100)
        }
        
        gameLayer.addChild(enemy)
    }
    
    /// 현재 스폰 상태 출력
    func debugPrintStatus() {
        print("""
        === EnemySpawner Status ===
        Is Spawning: \(isSpawning)
        Enemies Spawned: \(enemiesSpawnedInWave)
        Boss Spawned: \(bossSpawned)
        Spawn Interval: \(currentSpawnInterval)
        ===========================
        """)
    }
}
#endif
