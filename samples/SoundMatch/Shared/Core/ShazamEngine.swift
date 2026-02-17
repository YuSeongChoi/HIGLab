import Foundation
import ShazamKit
import AVFAudio
import Combine

// MARK: - ShazamEngineError
/// Shazam 엔진 오류 타입

enum ShazamEngineError: LocalizedError {
    case microphoneAccessDenied           // 마이크 권한 거부
    case audioEngineFailure(Error)        // 오디오 엔진 실패
    case sessionNotAvailable              // 세션 사용 불가
    case signatureGenerationFailed        // 시그니처 생성 실패
    case catalogNotLoaded                 // 카탈로그 로드 실패
    case matchingInProgress               // 이미 매칭 진행 중
    case unknown(Error)                   // 알 수 없는 오류
    
    var errorDescription: String? {
        switch self {
        case .microphoneAccessDenied:
            return "마이크 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
        case .audioEngineFailure(let error):
            return "오디오 엔진 오류: \(error.localizedDescription)"
        case .sessionNotAvailable:
            return "Shazam 세션을 시작할 수 없습니다."
        case .signatureGenerationFailed:
            return "오디오 시그니처 생성에 실패했습니다."
        case .catalogNotLoaded:
            return "카탈로그를 불러올 수 없습니다."
        case .matchingInProgress:
            return "이미 음악 인식이 진행 중입니다."
        case .unknown(let error):
            return "오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}

// MARK: - ShazamEngineState
/// Shazam 엔진 상태

enum ShazamEngineState: Equatable {
    case idle                    // 대기 중
    case preparingAudio          // 오디오 준비 중
    case listening               // 듣는 중
    case processingSignature     // 시그니처 처리 중
    case matching                // 매칭 중
    case matched                 // 매칭 성공
    case noMatch                 // 매칭 실패
    case error(ShazamEngineError) // 오류 발생
    
    static func == (lhs: ShazamEngineState, rhs: ShazamEngineState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.preparingAudio, .preparingAudio),
             (.listening, .listening), (.processingSignature, .processingSignature),
             (.matching, .matching), (.matched, .matched), (.noMatch, .noMatch):
            return true
        case (.error, .error):
            return true // 간단히 오류 상태만 비교
        default:
            return false
        }
    }
    
    /// 활성 상태 여부 (듣기 또는 처리 중)
    var isActive: Bool {
        switch self {
        case .preparingAudio, .listening, .processingSignature, .matching:
            return true
        default:
            return false
        }
    }
}

// MARK: - ShazamMatchResult
/// Shazam 매칭 결과

struct ShazamMatchResult: Sendable {
    /// 매칭된 미디어 아이템 (SHMatchedMediaItem)
    let matchedItem: SHMatchedMediaItem
    
    /// 원본 SHMatch
    let match: SHMatch
    
    /// 매칭 시간
    let matchedAt: Date
    
    /// 모든 매칭된 아이템들
    var allItems: [SHMatchedMediaItem] {
        match.mediaItems
    }
    
    /// 최고 신뢰도 아이템
    var bestMatch: SHMatchedMediaItem {
        matchedItem
    }
}

// MARK: - ShazamEngineDelegate
/// Shazam 엔진 델리게이트 프로토콜

@MainActor
protocol ShazamEngineDelegate: AnyObject {
    /// 상태 변경 시 호출
    func shazamEngine(_ engine: ShazamEngine, didChangeState state: ShazamEngineState)
    
    /// 매칭 성공 시 호출
    func shazamEngine(_ engine: ShazamEngine, didMatch result: ShazamMatchResult)
    
    /// 매칭 실패 시 호출 (SHSignature 포함)
    func shazamEngine(_ engine: ShazamEngine, didNotMatchFor signature: SHSignature)
    
    /// 시그니처 생성 시 호출 (실시간 모니터링용)
    func shazamEngine(_ engine: ShazamEngine, didGenerateSignature signature: SHSignature)
    
    /// 오류 발생 시 호출
    func shazamEngine(_ engine: ShazamEngine, didFailWith error: ShazamEngineError)
}

// MARK: - ShazamEngine
/// SHSession과 SHSessionDelegate를 사용한 고급 음악 인식 엔진
/// 커스텀 카탈로그와 실시간 오디오 처리 지원

@MainActor
@Observable
final class ShazamEngine: NSObject {
    // MARK: - 상태
    private(set) var state: ShazamEngineState = .idle {
        didSet {
            delegate?.shazamEngine(self, didChangeState: state)
        }
    }
    
    /// 마지막 매칭 결과
    private(set) var lastMatchResult: ShazamMatchResult?
    
    /// 마지막 생성된 시그니처
    private(set) var lastSignature: SHSignature?
    
    // MARK: - 델리게이트
    weak var delegate: ShazamEngineDelegate?
    
    // MARK: - ShazamKit 컴포넌트
    /// 기본 Shazam 세션 (SHSession)
    private var session: SHSession?
    
    /// 커스텀 카탈로그 세션
    private var customCatalogSession: SHSession?
    
    /// 현재 사용 중인 카탈로그
    private var currentCatalog: SHCatalog?
    
    /// 시그니처 생성기 (SHSignatureGenerator)
    private var signatureGenerator: SHSignatureGenerator?
    
    // MARK: - 오디오 컴포넌트
    /// AVAudioEngine for 오디오 캡처
    private let audioEngine = AVAudioEngine()
    
    /// 입력 노드
    private var inputNode: AVAudioInputNode {
        audioEngine.inputNode
    }
    
    // MARK: - 설정
    /// 자동 중지 활성화 (매칭 후 자동 중지)
    var autoStopOnMatch = true
    
    /// 실시간 시그니처 알림 활성화
    var enableRealtimeSignatureNotification = false
    
    /// 커스텀 카탈로그 우선 사용
    var preferCustomCatalog = false
    
    /// 오프라인 모드 (커스텀 카탈로그만 사용)
    var offlineMode = false
    
    // MARK: - 초기화
    override init() {
        super.init()
        setupSession()
    }
    
    // MARK: - 세션 설정
    /// 기본 Shazam 세션 초기화
    private func setupSession() {
        session = SHSession()
        session?.delegate = self
    }
    
    /// 커스텀 카탈로그로 세션 설정
    /// - Parameter catalog: SHCustomCatalog 인스턴스
    func configureWithCatalog(_ catalog: SHCustomCatalog) {
        currentCatalog = catalog
        customCatalogSession = SHSession(catalog: catalog)
        customCatalogSession?.delegate = self
    }
    
    /// 기본 카탈로그로 세션 설정
    /// - Parameter catalog: SHCatalog 인스턴스
    func configureWithBaseCatalog(_ catalog: SHCatalog) {
        currentCatalog = catalog
        customCatalogSession = SHSession(catalog: catalog)
        customCatalogSession?.delegate = self
    }
    
    // MARK: - 음악 인식 시작
    /// 마이크를 통한 실시간 음악 인식 시작
    func startListening() async throws {
        // 이미 진행 중이면 오류
        guard !state.isActive else {
            throw ShazamEngineError.matchingInProgress
        }
        
        // 마이크 권한 확인
        guard await requestMicrophonePermission() else {
            let error = ShazamEngineError.microphoneAccessDenied
            state = .error(error)
            throw error
        }
        
        state = .preparingAudio
        
        do {
            try await startAudioCapture()
            state = .listening
        } catch {
            let engineError = ShazamEngineError.audioEngineFailure(error)
            state = .error(engineError)
            throw engineError
        }
    }
    
    /// 오디오 캡처 시작 및 시그니처 생성
    private func startAudioCapture() async throws {
        // 시그니처 생성기 초기화
        signatureGenerator = SHSignatureGenerator()
        
        // 오디오 포맷 설정 (Shazam 권장 포맷)
        let format = inputNode.outputFormat(forBus: 0)
        
        // 입력 탭 설치
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] buffer, time in
            Task { @MainActor [weak self] in
                await self?.processAudioBuffer(buffer, time: time)
            }
        }
        
        // 오디오 세션 설정
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true)
        
        // 오디오 엔진 시작
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    /// 오디오 버퍼 처리 및 시그니처 생성
    @MainActor
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, time: AVAudioTime) async {
        guard state == .listening else { return }
        
        do {
            // 시그니처 생성기에 버퍼 추가
            try signatureGenerator?.append(buffer, at: time)
            
            // 현재 시그니처 가져오기
            if let signature = signatureGenerator?.signature() {
                lastSignature = signature
                
                // 실시간 시그니처 알림 (옵션)
                if enableRealtimeSignatureNotification {
                    delegate?.shazamEngine(self, didGenerateSignature: signature)
                }
                
                // 세션에 시그니처 매칭 요청
                // 적절한 간격으로 매칭 (예: 3초마다)
                await matchSignature(signature)
            }
        } catch {
            print("⚠️ 시그니처 생성 오류: \(error.localizedDescription)")
        }
    }
    
    /// 시그니처 매칭 요청
    private func matchSignature(_ signature: SHSignature) async {
        // 이미 매칭 중이면 스킵
        guard state == .listening else { return }
        
        state = .matching
        
        // 오프라인 모드이거나 커스텀 카탈로그 우선인 경우
        if offlineMode || preferCustomCatalog, let customSession = customCatalogSession {
            customSession.match(signature)
        } else if let session = session {
            session.match(signature)
        }
    }
    
    // MARK: - 파일에서 인식
    /// 오디오 파일에서 음악 인식
    /// - Parameter url: 오디오 파일 URL
    /// - Returns: 생성된 시그니처
    func recognizeFromFile(_ url: URL) async throws -> SHSignature {
        state = .processingSignature
        
        do {
            // 파일에서 시그니처 생성
            let generator = SHSignatureGenerator()
            let signature = try await generator.signature(from: url)
            
            lastSignature = signature
            state = .matching
            
            // 매칭 요청
            if offlineMode || preferCustomCatalog, let customSession = customCatalogSession {
                customSession.match(signature)
            } else {
                session?.match(signature)
            }
            
            return signature
        } catch {
            let engineError = ShazamEngineError.signatureGenerationFailed
            state = .error(engineError)
            throw engineError
        }
    }
    
    /// 시그니처 직접 매칭
    /// - Parameter signature: SHSignature 인스턴스
    func matchSignatureDirectly(_ signature: SHSignature) {
        guard !state.isActive else { return }
        
        state = .matching
        lastSignature = signature
        
        if offlineMode || preferCustomCatalog, let customSession = customCatalogSession {
            customSession.match(signature)
        } else {
            session?.match(signature)
        }
    }
    
    // MARK: - 인식 중지
    /// 음악 인식 중지
    func stopListening() {
        // 오디오 엔진 중지
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        
        // 오디오 세션 비활성화
        try? AVAudioSession.sharedInstance().setActive(false)
        
        // 상태 초기화 (활성 상태일 때만)
        if state.isActive {
            state = .idle
        }
        
        // 시그니처 생성기 초기화
        signatureGenerator = nil
    }
    
    /// 완전 초기화
    func reset() {
        stopListening()
        state = .idle
        lastMatchResult = nil
        lastSignature = nil
    }
    
    // MARK: - 마이크 권한
    /// 마이크 권한 요청
    private func requestMicrophonePermission() async -> Bool {
        let status = AVAudioApplication.shared.recordPermission
        
        switch status {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }
}

// MARK: - SHSessionDelegate
/// SHSessionDelegate 구현 - 핵심 매칭 결과 처리

extension ShazamEngine: SHSessionDelegate {
    /// 매칭 성공 콜백
    nonisolated func session(_ session: SHSession, didFind match: SHMatch) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            // 첫 번째 (최고 신뢰도) 아이템 사용
            guard let firstItem = match.mediaItems.first else {
                self.state = .noMatch
                return
            }
            
            // 결과 생성
            let result = ShazamMatchResult(
                matchedItem: firstItem,
                match: match,
                matchedAt: Date()
            )
            
            self.lastMatchResult = result
            self.state = .matched
            
            // 델리게이트 알림
            self.delegate?.shazamEngine(self, didMatch: result)
            
            // 자동 중지
            if self.autoStopOnMatch {
                self.stopListening()
            }
        }
    }
    
    /// 매칭 실패 콜백
    nonisolated func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            if let error = error {
                let engineError = ShazamEngineError.unknown(error)
                self.state = .error(engineError)
                self.delegate?.shazamEngine(self, didFailWith: engineError)
            } else {
                self.state = .noMatch
                self.delegate?.shazamEngine(self, didNotMatchFor: signature)
            }
            
            // 자동 중지
            if self.autoStopOnMatch {
                self.stopListening()
            }
        }
    }
}

// MARK: - 유틸리티 확장
extension ShazamEngine {
    /// 현재 세션이 커스텀 카탈로그를 사용 중인지 여부
    var isUsingCustomCatalog: Bool {
        currentCatalog != nil && (offlineMode || preferCustomCatalog)
    }
    
    /// 시그니처 데이터 내보내기
    func exportSignatureData() -> Data? {
        return lastSignature?.dataRepresentation
    }
    
    /// 데이터에서 시그니처 가져오기
    func importSignature(from data: Data) throws -> SHSignature {
        return try SHSignature(dataRepresentation: data)
    }
}
