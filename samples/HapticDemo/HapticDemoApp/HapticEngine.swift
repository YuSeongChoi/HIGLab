// HapticEngine.swift
// HapticDemo - Core Haptics 샘플
// CHHapticEngine을 관리하는 래퍼 클래스

import Foundation
import CoreHaptics
import AVFoundation

// MARK: - 햅틱 엔진 상태
/// 햅틱 엔진의 현재 상태
enum HapticEngineState: String {
    case notInitialized = "초기화 안됨"
    case ready = "준비됨"
    case playing = "재생 중"
    case stopped = "정지됨"
    case error = "오류"
}

// MARK: - 햅틱 엔진 에러
/// 햅틱 관련 에러 타입
enum HapticError: LocalizedError {
    case notSupported
    case engineCreationFailed
    case engineStartFailed
    case patternCreationFailed
    case playerCreationFailed
    case ahapLoadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notSupported:
            return "이 기기는 햅틱을 지원하지 않습니다."
        case .engineCreationFailed:
            return "햅틱 엔진 생성에 실패했습니다."
        case .engineStartFailed:
            return "햅틱 엔진 시작에 실패했습니다."
        case .patternCreationFailed:
            return "햅틱 패턴 생성에 실패했습니다."
        case .playerCreationFailed:
            return "햅틱 플레이어 생성에 실패했습니다."
        case .ahapLoadFailed(let filename):
            return "AHAP 파일 '\(filename)' 로드에 실패했습니다."
        }
    }
}

// MARK: - 햅틱 엔진 매니저
/// Core Haptics 엔진을 관리하고 햅틱 재생을 제어하는 클래스
@MainActor
class HapticEngineManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 현재 엔진 상태
    @Published private(set) var state: HapticEngineState = .notInitialized
    
    /// 햅틱 지원 여부
    @Published private(set) var supportsHaptics: Bool = false
    
    /// 현재 재생 중인 패턴 이름
    @Published private(set) var currentPatternName: String?
    
    /// 마지막 에러 메시지
    @Published private(set) var lastError: String?
    
    /// 전역 강도 조절 (0.0 ~ 1.0)
    @Published var globalIntensity: Float = 1.0 {
        didSet {
            updateDynamicParameters()
        }
    }
    
    /// 전역 선명도 조절 (0.0 ~ 1.0)
    @Published var globalSharpness: Float = 0.5 {
        didSet {
            updateDynamicParameters()
        }
    }
    
    // MARK: - Private Properties
    
    /// Core Haptics 엔진
    private var engine: CHHapticEngine?
    
    /// 현재 활성화된 패턴 플레이어
    private var patternPlayer: CHHapticPatternPlayer?
    
    /// 고급 패턴 플레이어 (다이나믹 파라미터 지원)
    private var advancedPlayer: CHHapticAdvancedPatternPlayer?
    
    /// 엔진 리셋 핸들러
    private var engineNeedsRestart: Bool = false
    
    // MARK: - Initialization
    
    init() {
        checkHapticCapability()
        setupEngine()
    }
    
    deinit {
        stopEngine()
    }
    
    // MARK: - Public Methods
    
    /// 햅틱 지원 여부 확인
    func checkHapticCapability() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        
        if !supportsHaptics {
            lastError = "이 기기는 햅틱을 지원하지 않습니다."
            state = .error
        }
    }
    
    /// 엔진 설정 및 시작
    func setupEngine() {
        guard supportsHaptics else { return }
        
        do {
            // 햅틱 엔진 생성
            engine = try CHHapticEngine()
            
            // 엔진 이벤트 핸들러 설정
            setupEngineCallbacks()
            
            // 엔진 시작
            try engine?.start()
            
            state = .ready
            lastError = nil
            
        } catch {
            state = .error
            lastError = "엔진 초기화 실패: \(error.localizedDescription)"
        }
    }
    
    /// 엔진 중지
    func stopEngine() {
        engine?.stop(completionHandler: { [weak self] error in
            Task { @MainActor in
                if let error = error {
                    self?.lastError = "엔진 중지 실패: \(error.localizedDescription)"
                }
                self?.state = .stopped
            }
        })
    }
    
    /// 엔진 재시작
    func restartEngine() {
        stopEngine()
        
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초 대기
            setupEngine()
        }
    }
    
    /// HapticPattern 모델 재생
    func playPattern(_ pattern: HapticPattern) throws {
        guard supportsHaptics, let engine = engine else {
            throw HapticError.notSupported
        }
        
        // 기존 재생 중지
        stopCurrentPlayback()
        
        do {
            // 패턴 변환
            let chPattern = try pattern.toCHHapticPattern()
            
            // 플레이어 생성
            if pattern.isLooping {
                // 루핑 패턴은 Advanced Player 사용
                advancedPlayer = try engine.makeAdvancedPlayer(with: chPattern)
                advancedPlayer?.loopEnabled = true
                try advancedPlayer?.start(atTime: CHHapticTimeImmediate)
            } else {
                // 단일 패턴은 기본 Player 사용
                patternPlayer = try engine.makePlayer(with: chPattern)
                try patternPlayer?.start(atTime: CHHapticTimeImmediate)
            }
            
            currentPatternName = pattern.name
            state = .playing
            
        } catch {
            throw HapticError.patternCreationFailed
        }
    }
    
    /// 프리셋 재생
    func playPreset(_ preset: HapticPreset) throws {
        try playPattern(preset.pattern)
    }
    
    /// AHAP 파일 재생
    func playAHAPFile(named filename: String) throws {
        guard supportsHaptics, let engine = engine else {
            throw HapticError.notSupported
        }
        
        // 번들에서 AHAP 파일 찾기
        guard let url = Bundle.main.url(forResource: filename, withExtension: "ahap") else {
            throw HapticError.ahapLoadFailed(filename)
        }
        
        stopCurrentPlayback()
        
        do {
            try engine.playPattern(from: url)
            currentPatternName = filename
            state = .playing
        } catch {
            throw HapticError.ahapLoadFailed(filename)
        }
    }
    
    /// AHAP 딕셔너리로 재생
    func playAHAPDictionary(_ ahapDict: [CHHapticPattern.Key: Any]) throws {
        guard supportsHaptics, let engine = engine else {
            throw HapticError.notSupported
        }
        
        stopCurrentPlayback()
        
        do {
            let pattern = try CHHapticPattern(dictionary: ahapDict)
            patternPlayer = try engine.makePlayer(with: pattern)
            try patternPlayer?.start(atTime: CHHapticTimeImmediate)
            state = .playing
        } catch {
            throw HapticError.patternCreationFailed
        }
    }
    
    /// 현재 재생 중지
    func stopCurrentPlayback() {
        do {
            try patternPlayer?.stop(atTime: CHHapticTimeImmediate)
            try advancedPlayer?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            // 이미 정지된 경우 무시
        }
        
        patternPlayer = nil
        advancedPlayer = nil
        currentPatternName = nil
        
        if state == .playing {
            state = .ready
        }
    }
    
    /// 일시 정지
    func pause() {
        do {
            try advancedPlayer?.pause(atTime: CHHapticTimeImmediate)
        } catch {
            lastError = "일시 정지 실패: \(error.localizedDescription)"
        }
    }
    
    /// 재개
    func resume() {
        do {
            try advancedPlayer?.resume(atTime: CHHapticTimeImmediate)
        } catch {
            lastError = "재개 실패: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 간편 햅틱 메서드
    
    /// 빠른 일시적 햅틱 (탭)
    func playTransientHaptic(intensity: Float = 1.0, sharpness: Float = 0.5) {
        guard supportsHaptics, let engine = engine else { return }
        
        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * globalIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            
        } catch {
            // 간편 메서드는 에러를 조용히 무시
        }
    }
    
    /// 연속 햅틱 재생
    func playContinuousHaptic(
        intensity: Float = 0.8,
        sharpness: Float = 0.5,
        duration: TimeInterval = 0.5
    ) {
        guard supportsHaptics, let engine = engine else { return }
        
        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * globalIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0,
                duration: duration
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            patternPlayer = try engine.makePlayer(with: pattern)
            try patternPlayer?.start(atTime: CHHapticTimeImmediate)
            
        } catch {
            // 에러 무시
        }
    }
    
    // MARK: - Private Methods
    
    /// 엔진 콜백 설정
    private func setupEngineCallbacks() {
        // 엔진이 중지되었을 때 호출
        engine?.stoppedHandler = { [weak self] reason in
            Task { @MainActor in
                self?.handleEngineStopped(reason: reason)
            }
        }
        
        // 엔진 리셋이 필요할 때 호출
        engine?.resetHandler = { [weak self] in
            Task { @MainActor in
                self?.handleEngineReset()
            }
        }
    }
    
    /// 엔진 중지 처리
    private func handleEngineStopped(reason: CHHapticEngine.StoppedReason) {
        let reasonString: String
        switch reason {
        case .audioSessionInterrupt:
            reasonString = "오디오 세션 인터럽트"
        case .applicationSuspended:
            reasonString = "앱 일시 정지"
        case .idleTimeout:
            reasonString = "유휴 타임아웃"
        case .systemError:
            reasonString = "시스템 오류"
        case .notifyWhenFinished:
            reasonString = "재생 완료"
        case .engineDestroyed:
            reasonString = "엔진 소멸"
        case .gameControllerDisconnect:
            reasonString = "게임 컨트롤러 연결 해제"
        @unknown default:
            reasonString = "알 수 없는 이유"
        }
        
        lastError = "엔진 중지: \(reasonString)"
        state = .stopped
        engineNeedsRestart = true
    }
    
    /// 엔진 리셋 처리
    private func handleEngineReset() {
        do {
            try engine?.start()
            state = .ready
            lastError = nil
        } catch {
            state = .error
            lastError = "엔진 재시작 실패: \(error.localizedDescription)"
        }
    }
    
    /// 다이나믹 파라미터 업데이트
    private func updateDynamicParameters() {
        guard let advancedPlayer = advancedPlayer else { return }
        
        do {
            let intensityParam = CHHapticDynamicParameter(
                parameterID: .hapticIntensityControl,
                value: globalIntensity,
                relativeTime: 0
            )
            
            let sharpnessParam = CHHapticDynamicParameter(
                parameterID: .hapticSharpnessControl,
                value: globalSharpness,
                relativeTime: 0
            )
            
            try advancedPlayer.sendParameters([intensityParam, sharpnessParam], atTime: CHHapticTimeImmediate)
        } catch {
            lastError = "파라미터 업데이트 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: - AHAP 헬퍼
extension HapticEngineManager {
    
    /// AHAP 패턴 딕셔너리 생성 헬퍼
    static func createAHAPPattern(events: [[String: Any]]) -> [CHHapticPattern.Key: Any] {
        return [
            CHHapticPattern.Key(rawValue: "Version"): 1.0,
            CHHapticPattern.Key(rawValue: "Pattern"): events
        ]
    }
    
    /// 단일 transient 이벤트 AHAP 딕셔너리
    static func transientEvent(
        time: Double,
        intensity: Double,
        sharpness: Double
    ) -> [String: Any] {
        return [
            "Event": [
                "Time": time,
                "EventType": "HapticTransient",
                "EventParameters": [
                    ["ParameterID": "HapticIntensity", "ParameterValue": intensity],
                    ["ParameterID": "HapticSharpness", "ParameterValue": sharpness]
                ]
            ]
        ]
    }
    
    /// 단일 continuous 이벤트 AHAP 딕셔너리
    static func continuousEvent(
        time: Double,
        duration: Double,
        intensity: Double,
        sharpness: Double
    ) -> [String: Any] {
        return [
            "Event": [
                "Time": time,
                "EventDuration": duration,
                "EventType": "HapticContinuous",
                "EventParameters": [
                    ["ParameterID": "HapticIntensity", "ParameterValue": intensity],
                    ["ParameterID": "HapticSharpness", "ParameterValue": sharpness]
                ]
            ]
        ]
    }
}
