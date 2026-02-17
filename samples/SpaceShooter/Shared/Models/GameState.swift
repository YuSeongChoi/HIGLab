// GameState.swift
// SpaceShooter - SpriteKit 2D 게임
// 게임 상태 관리 모델

import Foundation
import Combine

/// 게임의 현재 상태를 나타내는 열거형
enum GameStatus: Equatable {
    /// 게임 시작 전 대기 상태
    case ready
    
    /// 게임 진행 중
    case playing
    
    /// 일시 정지
    case paused
    
    /// 게임 오버
    case gameOver
}

/// 게임 난이도 레벨
enum DifficultyLevel: Int, CaseIterable {
    case easy = 1
    case normal = 2
    case hard = 3
    case insane = 4
    
    /// 적 스폰 간격 (초)
    var spawnInterval: TimeInterval {
        switch self {
        case .easy: return 2.0
        case .normal: return 1.5
        case .hard: return 1.0
        case .insane: return 0.6
        }
    }
    
    /// 적 이동 속도 배율
    var enemySpeedMultiplier: CGFloat {
        switch self {
        case .easy: return 0.8
        case .normal: return 1.0
        case .hard: return 1.3
        case .insane: return 1.8
        }
    }
    
    /// 적 체력 배율
    var enemyHealthMultiplier: Int {
        switch self {
        case .easy: return 1
        case .normal: return 1
        case .hard: return 2
        case .insane: return 3
        }
    }
    
    /// 난이도 이름 (한글)
    var displayName: String {
        switch self {
        case .easy: return "쉬움"
        case .normal: return "보통"
        case .hard: return "어려움"
        case .insane: return "극한"
        }
    }
}

/// 게임 전체 상태를 관리하는 ObservableObject
/// SwiftUI와 SpriteKit 간의 상태 공유에 사용됩니다.
final class GameState: ObservableObject {
    // MARK: - Published 프로퍼티
    
    /// 현재 게임 상태
    @Published var status: GameStatus = .ready
    
    /// 현재 점수
    @Published var score: Int = 0
    
    /// 최고 점수
    @Published var highScore: Int = 0
    
    /// 플레이어 남은 생명
    @Published var lives: Int = 3
    
    /// 현재 난이도
    @Published var difficulty: DifficultyLevel = .normal
    
    /// 현재 웨이브 (라운드)
    @Published var wave: Int = 1
    
    /// 처치한 적 수
    @Published var enemiesDefeated: Int = 0
    
    /// 게임 플레이 시간 (초)
    @Published var playTime: TimeInterval = 0
    
    // MARK: - 상수
    
    /// 초기 생명 수
    static let initialLives = 3
    
    /// 최대 생명 수
    static let maxLives = 5
    
    /// 웨이브당 필요 처치 수
    static let enemiesPerWave = 10
    
    /// 점수당 생명 획득 (이 점수마다 생명 +1)
    static let scorePerLife = 5000
    
    // MARK: - UserDefaults 키
    
    private let highScoreKey = "SpaceShooter.HighScore"
    
    // MARK: - 초기화
    
    init() {
        loadHighScore()
    }
    
    // MARK: - 게임 제어 메서드
    
    /// 새 게임 시작
    func startGame() {
        score = 0
        lives = GameState.initialLives
        wave = 1
        enemiesDefeated = 0
        playTime = 0
        status = .playing
    }
    
    /// 게임 일시 정지
    func pauseGame() {
        guard status == .playing else { return }
        status = .paused
    }
    
    /// 게임 재개
    func resumeGame() {
        guard status == .paused else { return }
        status = .playing
    }
    
    /// 게임 오버 처리
    func endGame() {
        status = .gameOver
        updateHighScore()
    }
    
    /// 게임 리셋 (메뉴로 돌아가기)
    func resetGame() {
        status = .ready
        score = 0
        lives = GameState.initialLives
        wave = 1
        enemiesDefeated = 0
        playTime = 0
    }
    
    // MARK: - 점수 및 상태 업데이트
    
    /// 점수 추가
    /// - Parameter points: 추가할 점수
    func addScore(_ points: Int) {
        let oldScore = score
        score += points
        
        // 일정 점수마다 생명 추가
        let oldLifeThreshold = oldScore / GameState.scorePerLife
        let newLifeThreshold = score / GameState.scorePerLife
        
        if newLifeThreshold > oldLifeThreshold && lives < GameState.maxLives {
            lives += 1
        }
    }
    
    /// 적 처치 카운트 증가 및 웨이브 체크
    func enemyDefeated() {
        enemiesDefeated += 1
        
        // 웨이브 클리어 체크
        if enemiesDefeated >= wave * GameState.enemiesPerWave {
            advanceWave()
        }
    }
    
    /// 다음 웨이브로 진행
    private func advanceWave() {
        wave += 1
        
        // 난이도 자동 상승
        if wave >= 5 && difficulty == .easy {
            difficulty = .normal
        } else if wave >= 10 && difficulty == .normal {
            difficulty = .hard
        } else if wave >= 15 && difficulty == .hard {
            difficulty = .insane
        }
    }
    
    /// 플레이어 피격 처리
    /// - Returns: 게임 오버 여부
    @discardableResult
    func playerHit() -> Bool {
        lives -= 1
        
        if lives <= 0 {
            endGame()
            return true
        }
        return false
    }
    
    /// 생명 추가 (파워업)
    func addLife() {
        if lives < GameState.maxLives {
            lives += 1
        }
    }
    
    // MARK: - 최고 점수 관리
    
    /// 최고 점수 로드
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    /// 최고 점수 업데이트
    private func updateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }
    }
    
    // MARK: - 게임 시간 업데이트
    
    /// 게임 시간 업데이트 (매 프레임 호출)
    /// - Parameter deltaTime: 이전 프레임 이후 경과 시간
    func updatePlayTime(_ deltaTime: TimeInterval) {
        guard status == .playing else { return }
        playTime += deltaTime
    }
    
    /// 포맷된 플레이 시간 문자열
    var formattedPlayTime: String {
        let minutes = Int(playTime) / 60
        let seconds = Int(playTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
