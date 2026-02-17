// ChatService.swift
// Foundation Models LanguageModel 서비스
// iOS 26+ | FoundationModels
//
// LanguageModel과의 통신을 담당하는 핵심 서비스
// 스트리밍 응답, 도구 호출, 세션 관리 등을 처리

import Foundation
import FoundationModels

// MARK: - 채팅 서비스

/// 채팅 서비스 - LanguageModel과의 통신 담당
/// Foundation Models의 모든 기능을 캡슐화하여 제공
@MainActor
@Observable
final class ChatService {
    
    // MARK: - 상태
    
    /// 현재 스트리밍 중인 응답 텍스트
    private(set) var streamingText: String = ""
    
    /// 응답 생성 중 여부
    private(set) var isGenerating: Bool = false
    
    /// 에러 메시지
    private(set) var errorMessage: String?
    
    /// 마지막 응답의 토큰 사용량
    private(set) var lastTokenUsage: TokenUsage?
    
    /// 응답 시작 시간 (성능 측정용)
    private var responseStartTime: Date?
    
    /// 마지막 응답 시간 (초)
    private(set) var lastResponseTime: TimeInterval?
    
    // MARK: - LanguageModel 구성
    
    /// 현재 세션
    private var session: LanguageModelSession?
    
    /// 현재 시스템 프롬프트
    private(set) var systemPrompt: String
    
    /// 현재 생성 옵션
    private(set) var generationOptions: GenerationOptions
    
    /// 등록된 도구들
    private var registeredTools: [any Tool] = []
    
    /// 현재 Task (취소용)
    private var currentTask: Task<String, Error>?
    
    // MARK: - 초기화
    
    init(
        systemPrompt: String = ConversationSettings.defaultSystemPrompt,
        options: GenerationOptions = .default
    ) {
        self.systemPrompt = systemPrompt
        self.generationOptions = options
        setupSession()
    }
    
    // MARK: - 세션 관리
    
    /// 세션 초기화 (새 대화 시작)
    func resetSession() {
        setupSession()
        streamingText = ""
        errorMessage = nil
        lastTokenUsage = nil
        lastResponseTime = nil
    }
    
    /// 세션 구성
    private func setupSession() {
        // 도구가 있으면 도구와 함께 세션 생성
        if !registeredTools.isEmpty {
            session = LanguageModelSession(
                instructions: systemPrompt,
                tools: registeredTools
            )
        } else {
            session = LanguageModelSession(
                instructions: systemPrompt
            )
        }
    }
    
    /// 시스템 프롬프트 업데이트
    /// - Parameter prompt: 새 시스템 프롬프트
    func updateSystemPrompt(_ prompt: String) {
        systemPrompt = prompt
        setupSession()
    }
    
    /// 생성 옵션 업데이트
    /// - Parameter options: 새 생성 옵션
    func updateGenerationOptions(_ options: GenerationOptions) {
        generationOptions = options
    }
    
    // MARK: - 도구 관리
    
    /// 도구 등록
    /// - Parameter tool: 등록할 도구
    func registerTool(_ tool: any Tool) {
        registeredTools.append(tool)
        setupSession()
    }
    
    /// 여러 도구 등록
    /// - Parameter tools: 등록할 도구들
    func registerTools(_ tools: [any Tool]) {
        registeredTools.append(contentsOf: tools)
        setupSession()
    }
    
    /// 도구 초기화
    func clearTools() {
        registeredTools.removeAll()
        setupSession()
    }
    
    /// 등록된 도구 이름 목록
    var registeredToolNames: [String] {
        registeredTools.map { type(of: $0).name }
    }
    
    // MARK: - 메시지 전송
    
    /// 메시지를 전송하고 스트리밍 응답 받기
    /// - Parameter content: 사용자 메시지 내용
    /// - Returns: 완성된 AI 응답 텍스트
    func send(_ content: String) async throws -> String {
        guard !isGenerating else {
            throw ChatServiceError.alreadyGenerating
        }
        
        guard let session else {
            throw ChatServiceError.sessionNotAvailable
        }
        
        // 상태 초기화
        isGenerating = true
        streamingText = ""
        errorMessage = nil
        responseStartTime = Date()
        
        defer {
            isGenerating = false
            if let start = responseStartTime {
                lastResponseTime = Date().timeIntervalSince(start)
            }
        }
        
        do {
            // 스트리밍 응답 요청
            let stream = session.streamResponse(to: content)
            
            // 스트림에서 텍스트 조각들을 수집
            for try await partial in stream {
                streamingText = partial.outputSoFar
            }
            
            let finalText = streamingText
            
            // 토큰 사용량 추정 (Foundation Models는 직접 제공하지 않으므로 추정)
            lastTokenUsage = estimateTokenUsage(
                prompt: content,
                completion: finalText
            )
            
            return finalText
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 메시지 전송 (스트리밍 콜백 포함)
    /// - Parameters:
    ///   - content: 사용자 메시지 내용
    ///   - onPartial: 부분 응답 콜백
    /// - Returns: 완성된 AI 응답 텍스트
    func send(
        _ content: String,
        onPartial: @escaping (String) -> Void
    ) async throws -> String {
        guard !isGenerating else {
            throw ChatServiceError.alreadyGenerating
        }
        
        guard let session else {
            throw ChatServiceError.sessionNotAvailable
        }
        
        isGenerating = true
        streamingText = ""
        errorMessage = nil
        responseStartTime = Date()
        
        defer {
            isGenerating = false
            if let start = responseStartTime {
                lastResponseTime = Date().timeIntervalSince(start)
            }
        }
        
        do {
            let stream = session.streamResponse(to: content)
            
            for try await partial in stream {
                streamingText = partial.outputSoFar
                onPartial(partial.outputSoFar)
            }
            
            let finalText = streamingText
            
            lastTokenUsage = estimateTokenUsage(
                prompt: content,
                completion: finalText
            )
            
            return finalText
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 비스트리밍 응답 요청
    /// - Parameter content: 사용자 메시지 내용
    /// - Returns: 완성된 AI 응답 텍스트
    func sendNonStreaming(_ content: String) async throws -> String {
        guard !isGenerating else {
            throw ChatServiceError.alreadyGenerating
        }
        
        guard let session else {
            throw ChatServiceError.sessionNotAvailable
        }
        
        isGenerating = true
        errorMessage = nil
        responseStartTime = Date()
        
        defer {
            isGenerating = false
            if let start = responseStartTime {
                lastResponseTime = Date().timeIntervalSince(start)
            }
        }
        
        do {
            let response = try await session.respond(to: content)
            let text = response.content
            
            lastTokenUsage = estimateTokenUsage(
                prompt: content,
                completion: text
            )
            
            return text
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - 응답 취소
    
    /// 현재 응답 생성 취소
    func cancel() {
        currentTask?.cancel()
        currentTask = nil
        isGenerating = false
        streamingText = ""
    }
    
    // MARK: - 토큰 추정
    
    /// 토큰 사용량 추정 (근사치)
    /// - Parameters:
    ///   - prompt: 프롬프트 텍스트
    ///   - completion: 생성된 텍스트
    /// - Returns: 추정된 토큰 사용량
    private func estimateTokenUsage(prompt: String, completion: String) -> TokenUsage {
        // 한글 기준 대략 2~3글자당 1토큰으로 추정
        // 영문은 4글자당 1토큰으로 추정
        let promptTokens = estimateTokenCount(prompt)
        let completionTokens = estimateTokenCount(completion)
        
        return TokenUsage(
            promptTokens: promptTokens,
            completionTokens: completionTokens
        )
    }
    
    /// 텍스트의 토큰 수 추정
    private func estimateTokenCount(_ text: String) -> Int {
        var totalTokens = 0
        
        for char in text {
            if char.isASCII {
                // 영문/숫자/기호: 4글자당 1토큰
                totalTokens += 1
            } else {
                // 한글 등 유니코드: 2글자당 1토큰
                totalTokens += 2
            }
        }
        
        return max(1, totalTokens / 4)
    }
}

// MARK: - 생성 옵션

/// AI 응답 생성 옵션
struct GenerationOptions: Codable, Sendable, Hashable {
    
    /// 창의성 (0.0~2.0)
    var temperature: Double
    
    /// 확률 누적 (0.0~1.0)
    var topP: Double
    
    /// 최대 토큰 수
    var maxTokens: Int
    
    /// 반복 패널티
    var presencePenalty: Double
    
    /// 빈도 패널티
    var frequencyPenalty: Double
    
    /// 기본 옵션
    static let `default` = GenerationOptions()
    
    init(
        temperature: Double = 0.7,
        topP: Double = 1.0,
        maxTokens: Int = 4096,
        presencePenalty: Double = 0.0,
        frequencyPenalty: Double = 0.0
    ) {
        self.temperature = temperature
        self.topP = topP
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
    }
    
    /// 창의적 옵션
    static let creative = GenerationOptions(
        temperature: 1.2,
        topP: 0.95,
        presencePenalty: 0.5,
        frequencyPenalty: 0.5
    )
    
    /// 정확한 옵션
    static let precise = GenerationOptions(
        temperature: 0.3,
        topP: 0.9,
        presencePenalty: 0.0,
        frequencyPenalty: 0.0
    )
}

// MARK: - 에러 정의

/// 채팅 서비스 에러
enum ChatServiceError: LocalizedError {
    case alreadyGenerating          // 이미 생성 중
    case sessionNotAvailable        // 세션 사용 불가
    case modelUnavailable           // 모델 사용 불가
    case responseEmpty              // 빈 응답
    case toolExecutionFailed(String) // 도구 실행 실패
    case invalidPrompt              // 유효하지 않은 프롬프트
    case timeout                    // 타임아웃
    case cancelled                  // 취소됨
    case unknown(Error)             // 알 수 없는 에러
    
    var errorDescription: String? {
        switch self {
        case .alreadyGenerating:
            return "이미 응답을 생성 중입니다. 잠시 기다려주세요."
        case .sessionNotAvailable:
            return "세션을 사용할 수 없습니다. 앱을 다시 시작해주세요."
        case .modelUnavailable:
            return "이 기기에서는 언어 모델을 사용할 수 없습니다."
        case .responseEmpty:
            return "AI로부터 응답을 받지 못했습니다."
        case .toolExecutionFailed(let tool):
            return "도구 '\(tool)' 실행에 실패했습니다."
        case .invalidPrompt:
            return "유효하지 않은 메시지입니다."
        case .timeout:
            return "응답 시간이 초과되었습니다."
        case .cancelled:
            return "응답 생성이 취소되었습니다."
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence가 지원되는 기기에서 사용해주세요."
        case .sessionNotAvailable:
            return "앱을 완전히 종료 후 다시 시작해주세요."
        case .timeout:
            return "네트워크 연결을 확인하고 다시 시도해주세요."
        default:
            return nil
        }
    }
}

// MARK: - 모델 가용성

extension ChatService {
    
    /// 디바이스에서 모델 사용 가능 여부 확인
    static var isModelAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }
    
    /// 모델 가용성 상세 확인
    static func checkAvailability() async -> ModelAvailability {
        let availability = SystemLanguageModel.default.availability
        
        switch availability {
        case .available:
            return .available
        case .unavailable:
            return .unavailable(reason: "이 기기에서 Apple Intelligence를 사용할 수 없습니다.")
        @unknown default:
            return .unknown
        }
    }
    
    /// 모델 기능 확인
    static var modelCapabilities: ModelCapabilities {
        ModelCapabilities(
            supportsStreaming: true,
            supportsTools: true,
            supportsImages: false,
            maxContextLength: 4096,
            supportedLanguages: ["ko", "en", "ja", "zh"]
        )
    }
}

/// 모델 가용성 상태
enum ModelAvailability: Sendable {
    case available                      // 사용 가능
    case unavailable(reason: String)    // 사용 불가
    case downloading(progress: Double)  // 다운로드 중
    case unknown                        // 알 수 없음
    
    var isAvailable: Bool {
        if case .available = self {
            return true
        }
        return false
    }
    
    var displayText: String {
        switch self {
        case .available:
            return "사용 가능"
        case .unavailable(let reason):
            return reason
        case .downloading(let progress):
            return "다운로드 중 (\(Int(progress * 100))%)"
        case .unknown:
            return "확인 중..."
        }
    }
}

/// 모델 기능 정보
struct ModelCapabilities: Sendable {
    let supportsStreaming: Bool
    let supportsTools: Bool
    let supportsImages: Bool
    let maxContextLength: Int
    let supportedLanguages: [String]
}

// MARK: - 프리뷰 지원

extension ChatService {
    
    /// 프리뷰용 서비스
    static var preview: ChatService {
        ChatService()
    }
}
