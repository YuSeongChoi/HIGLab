import FoundationModels

@MainActor
class ChatViewModel: ObservableObject {
    @Published var response = ""
    
    private let model = LanguageModel.default
    
    func sendMessage(_ prompt: String) async {
        do {
            // 간단한 텍스트 생성
            let result = try await model.generate(prompt: prompt)
            response = result.text
        } catch {
            response = "오류: \(error.localizedDescription)"
        }
    }
}

// 시스템 프롬프트 설정
func createAssistant() -> LanguageModel.Session {
    let session = LanguageModel.default.createSession(
        systemPrompt: "당신은 친절한 한국어 AI 어시스턴트입니다."
    )
    return session
}
