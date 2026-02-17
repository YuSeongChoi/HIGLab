import FoundationModels
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    
    private var session: LanguageModel.Session?
    
    // 시스템 프롬프트로 모델 역할 정의
    func startNewChat(persona: String) {
        let systemPrompt = """
        당신은 \(persona)입니다.
        항상 친절하고 도움이 되는 방식으로 응답하세요.
        한국어로 대화합니다.
        """
        
        session = LanguageModel.default.createSession(
            systemPrompt: systemPrompt
        )
        messages = []
    }
    
    // 멀티턴 대화 - 이전 컨텍스트가 자동으로 유지됨
    func send(_ userMessage: String) async {
        guard let session else { return }
        
        messages.append(ChatMessage(role: .user, content: userMessage))
        isProcessing = true
        
        do {
            // Session이 대화 기록을 자동으로 관리
            let response = try await session.generate(prompt: userMessage)
            messages.append(ChatMessage(role: .assistant, content: response))
        } catch {
            messages.append(ChatMessage(role: .assistant, content: "오류가 발생했습니다."))
        }
        
        isProcessing = false
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    
    enum Role { case user, assistant }
}

// 대화 예시:
// User: "안녕하세요, 저는 김철수입니다"
// Assistant: "안녕하세요 김철수님, 만나서 반갑습니다!"
// User: "제 이름을 기억하시나요?"
// Assistant: "네, 김철수님이시죠!" ← 이전 컨텍스트 기억
