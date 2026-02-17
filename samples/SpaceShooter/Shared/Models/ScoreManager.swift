// ScoreManager.swift
// SpaceShooter - SpriteKit 2D 게임
// 점수 계산 및 콤보 시스템

import Foundation

/// 적 유형별 기본 점수
enum EnemyScore: Int {
    /// 일반 적
    case basic = 100
    
    /// 빠른 적
    case fast = 150
    
    /// 강한 적
    case heavy = 200
    
    /// 보스 적
    case boss = 1000
}

/// 점수 계산 및 콤보 시스템을 관리하는 클래스
final class ScoreManager {
    // MARK: - 싱글톤
    
    static let shared = ScoreManager()
    
    private init() {}
    
    // MARK: - 콤보 시스템
    
    /// 현재 콤보 수
    private(set) var currentCombo: Int = 0
    
    /// 최대 콤보 기록
    private(set) var maxCombo: Int = 0
    
    /// 마지막 처치 시간
    private var lastKillTime: TimeInterval = 0
    
    /// 콤보 유지 시간 (초)
    private let comboWindow: TimeInterval = 2.0
    
    /// 콤보 배율 상한
    private let maxComboMultiplier: Double = 5.0
    
    // MARK: - 점수 계산
    
    /// 적 처치 시 점수 계산
    /// - Parameters:
    ///   - baseScore: 기본 점수
    ///   - currentTime: 현재 게임 시간
    ///   - wave: 현재 웨이브
    /// - Returns: 계산된 최종 점수
    func calculateScore(baseScore: Int, currentTime: TimeInterval, wave: Int) -> Int {
        // 콤보 업데이트
        updateCombo(currentTime: currentTime)
        
        // 콤보 배율 계산 (최대 5배)
        let comboMultiplier = min(1.0 + Double(currentCombo) * 0.1, maxComboMultiplier)
        
        // 웨이브 보너스 (웨이브당 10% 추가)
        let waveMultiplier = 1.0 + Double(wave - 1) * 0.1
        
        // 최종 점수 계산
        let finalScore = Double(baseScore) * comboMultiplier * waveMultiplier
        
        return Int(finalScore)
    }
    
    /// 콤보 업데이트
    /// - Parameter currentTime: 현재 게임 시간
    private func updateCombo(currentTime: TimeInterval) {
        if currentTime - lastKillTime <= comboWindow {
            // 콤보 윈도우 내 처치 - 콤보 증가
            currentCombo += 1
        } else {
            // 콤보 윈도우 초과 - 콤보 리셋
            currentCombo = 1
        }
        
        lastKillTime = currentTime
        
        // 최대 콤보 갱신
        if currentCombo > maxCombo {
            maxCombo = currentCombo
        }
    }
    
    /// 콤보 리셋 (플레이어 피격 시)
    func resetCombo() {
        currentCombo = 0
    }
    
    /// 게임 시작 시 전체 리셋
    func resetAll() {
        currentCombo = 0
        maxCombo = 0
        lastKillTime = 0
    }
    
    // MARK: - 콤보 배율 조회
    
    /// 현재 콤보 배율
    var comboMultiplier: Double {
        return min(1.0 + Double(currentCombo) * 0.1, maxComboMultiplier)
    }
    
    /// 콤보 배율 표시 문자열
    var comboDisplayString: String {
        if currentCombo <= 1 {
            return ""
        }
        return "x\(currentCombo) COMBO!"
    }
    
    // MARK: - 보너스 점수 계산
    
    /// 웨이브 클리어 보너스 점수
    /// - Parameter wave: 클리어한 웨이브
    /// - Returns: 보너스 점수
    func waveCompletionBonus(wave: Int) -> Int {
        return wave * 500
    }
    
    /// 노 데미지 보너스 (웨이브 중 피격 없음)
    /// - Parameter wave: 현재 웨이브
    /// - Returns: 보너스 점수
    func noDamageBonus(wave: Int) -> Int {
        return wave * 1000
    }
    
    /// 스피드 클리어 보너스
    /// - Parameters:
    ///   - wave: 현재 웨이브
    ///   - clearTime: 클리어 시간 (초)
    /// - Returns: 보너스 점수
    func speedClearBonus(wave: Int, clearTime: TimeInterval) -> Int {
        // 기준 시간: 웨이브당 30초
        let targetTime = TimeInterval(wave * 30)
        
        if clearTime < targetTime {
            let timeSaved = targetTime - clearTime
            return Int(timeSaved * 10) * wave
        }
        return 0
    }
}
