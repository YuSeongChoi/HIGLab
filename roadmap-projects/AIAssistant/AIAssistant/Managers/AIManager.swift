import Foundation
import FoundationModels

@Observable
final class AIManager {
    private var session: LanguageModelSession?
    
    private(set) var isGenerating = false
    private(set) var currentResponse = ""
    private(set) var isAvailable = false
    
    init() {
        Task {
            await checkAvailability()
        }
    }
    
    // MARK: - Availability Check
    @MainActor
    func checkAvailability() async {
        let status = SystemLanguageModel.default.availability
        
        switch status {
        case .available:
            isAvailable = true
        case .unavailable:
            isAvailable = false
        @unknown default:
            isAvailable = false
        }
    }
    
    // MARK: - Create Session
    @MainActor
    func createSession(systemPrompt: String = "당신은 친절하고 도움이 되는 AI 어시스턴트입니다. 한국어로 답변해주세요.") {
        let instructions = SystemLanguageModel.Instructions(systemPrompt)
        session = LanguageModelSession(instructions: instructions)
    }
    
    // MARK: - Send Message (Streaming)
    @MainActor
    func sendMessage(_ text: String) async throws -> String {
        guard isAvailable else {
            throw AIError.notAvailable
        }
        
        if session == nil {
            createSession()
        }
        
        guard let session else {
            throw AIError.sessionNotCreated
        }
        
        isGenerating = true
        currentResponse = ""
        
        defer { isGenerating = false }
        
        // 스트리밍 응답
        let stream = session.streamResponse(to: text)
        
        for try await partial in stream {
            currentResponse = partial.content
        }
        
        return currentResponse
    }
    
    // MARK: - Send Message (Non-streaming)
    @MainActor
    func sendMessageSync(_ text: String) async throws -> String {
        guard isAvailable else {
            throw AIError.notAvailable
        }
        
        if session == nil {
            createSession()
        }
        
        guard let session else {
            throw AIError.sessionNotCreated
        }
        
        isGenerating = true
        defer { isGenerating = false }
        
        let response = try await session.respond(to: text)
        return response.content
    }
    
    // MARK: - Reset Session
    func resetSession() {
        session = nil
    }
    
    enum AIError: LocalizedError {
        case notAvailable
        case sessionNotCreated
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "AI 모델을 사용할 수 없습니다. iOS 26 이상 및 Apple Silicon이 필요합니다."
            case .sessionNotCreated:
                return "AI 세션을 생성할 수 없습니다."
            }
        }
    }
}
