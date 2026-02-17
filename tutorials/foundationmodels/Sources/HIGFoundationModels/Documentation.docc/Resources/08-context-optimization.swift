import FoundationModels

// 대화 요약을 통한 컨텍스트 최적화
class OptimizedChat {
    private var session: LanguageModel.Session
    private var conversationSummary: String = ""
    private var recentMessages: [(role: String, content: String)] = []
    
    private let maxRecentMessages = 6  // 최근 메시지만 유지
    private let summaryThreshold = 10  // 이 수 이상이면 요약 생성
    
    init() {
        self.session = LanguageModel.default.createSession()
    }
    
    func send(_ message: String) async throws -> String {
        recentMessages.append(("user", message))
        
        // 메시지가 많아지면 요약 생성
        if recentMessages.count >= summaryThreshold {
            try await compressHistory()
        }
        
        // 컨텍스트 구성: 요약 + 최근 메시지
        let contextPrompt = buildContextPrompt(newMessage: message)
        let response = try await session.generate(prompt: contextPrompt)
        
        recentMessages.append(("assistant", response))
        
        // 최근 메시지만 유지
        if recentMessages.count > maxRecentMessages {
            recentMessages.removeFirst(recentMessages.count - maxRecentMessages)
        }
        
        return response
    }
    
    private func compressHistory() async throws {
        // 이전 대화를 요약
        let historyText = recentMessages.map { "\($0.role): \($0.content)" }.joined(separator: "\n")
        
        let summaryPrompt = """
        다음 대화의 핵심 내용을 3문장으로 요약하세요:
        
        \(historyText)
        """
        
        let newSummary = try await session.generate(prompt: summaryPrompt)
        
        // 기존 요약과 병합
        if conversationSummary.isEmpty {
            conversationSummary = newSummary
        } else {
            conversationSummary = "\(conversationSummary)\n\(newSummary)"
        }
        
        // 오래된 메시지 제거
        recentMessages.removeFirst(summaryThreshold - maxRecentMessages)
    }
    
    private func buildContextPrompt(newMessage: String) -> String {
        var prompt = ""
        
        if !conversationSummary.isEmpty {
            prompt += "[이전 대화 요약]\n\(conversationSummary)\n\n"
        }
        
        prompt += "[최근 대화]\n"
        for msg in recentMessages.dropLast() {  // 마지막은 현재 메시지
            prompt += "\(msg.role): \(msg.content)\n"
        }
        
        prompt += "\n[현재 질문]\n\(newMessage)"
        
        return prompt
    }
}

// 선택적 컨텍스트 유지 전략
struct SmartContextManager {
    // 중요도에 따라 메시지 유지 여부 결정
    static func filterMessages(
        messages: [(role: String, content: String, importance: Double)]
    ) -> [(role: String, content: String)] {
        // 중요도 0.5 이상인 메시지만 유지
        return messages
            .filter { $0.importance >= 0.5 }
            .map { ($0.role, $0.content) }
    }
}
