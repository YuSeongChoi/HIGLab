import FoundationModels

// 컨텍스트 윈도우 관리
class ContextAwareChat {
    private var session: LanguageModel.Session
    private var messageHistory: [Message] = []
    
    // 온디바이스 모델의 일반적인 컨텍스트 제한
    private let maxContextTokens = 4096
    private let reservedForResponse = 512  // 응답을 위한 여유 공간
    
    struct Message {
        let role: Role
        let content: String
        let estimatedTokens: Int
        
        enum Role { case system, user, assistant }
    }
    
    init(systemPrompt: String) {
        self.session = LanguageModel.default.createSession(
            systemPrompt: systemPrompt
        )
        
        // 시스템 프롬프트도 토큰으로 계산
        let systemTokens = estimateTokenCount(systemPrompt)
        messageHistory.append(Message(
            role: .system,
            content: systemPrompt,
            estimatedTokens: systemTokens
        ))
    }
    
    // 대략적인 토큰 수 추정 (한국어 기준)
    private func estimateTokenCount(_ text: String) -> Int {
        // 한국어는 대략 글자당 1-2토큰
        return Int(Double(text.count) * 1.5)
    }
    
    // 현재 사용 중인 토큰 수
    var currentTokenUsage: Int {
        messageHistory.reduce(0) { $0 + $1.estimatedTokens }
    }
    
    // 남은 토큰 공간
    var availableTokens: Int {
        maxContextTokens - currentTokenUsage - reservedForResponse
    }
    
    func send(_ userMessage: String) async throws -> String {
        let userTokens = estimateTokenCount(userMessage)
        
        // 컨텍스트가 부족하면 오래된 메시지 제거
        while availableTokens < userTokens && messageHistory.count > 1 {
            // 시스템 프롬프트는 유지하고 가장 오래된 대화부터 제거
            messageHistory.remove(at: 1)
        }
        
        messageHistory.append(Message(
            role: .user,
            content: userMessage,
            estimatedTokens: userTokens
        ))
        
        let response = try await session.generate(prompt: userMessage)
        
        messageHistory.append(Message(
            role: .assistant,
            content: response,
            estimatedTokens: estimateTokenCount(response)
        ))
        
        return response
    }
}
