import AppIntents
import FoundationModels

// MARK: - Ask AI Intent
struct AskAIIntent: AppIntent {
    static var title: LocalizedStringResource = "AI에게 질문하기"
    static var description = IntentDescription("AI 어시스턴트에게 질문합니다.")
    
    @Parameter(title: "질문", requestValueDialog: "무엇을 물어볼까요?")
    var question: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("AI에게 \(\.$question) 물어보기")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        // Foundation Models 사용
        let session = LanguageModelSession()
        
        do {
            let response = try await session.respond(to: question)
            return .result(
                value: response.content,
                dialog: IntentDialog(stringLiteral: response.content)
            )
        } catch {
            return .result(
                value: "죄송합니다, 답변을 생성할 수 없습니다.",
                dialog: "AI 응답 생성 중 오류가 발생했습니다."
            )
        }
    }
    
    // Siri 제안
    static var openAppWhenRun: Bool = false
}

// MARK: - App Shortcuts Provider
struct AIShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AskAIIntent(),
            phrases: [
                "AI한테 물어봐 \(.applicationName)",
                "\(.applicationName)에서 \(\.$question) 물어봐",
                "AI 어시스턴트한테 질문해줘 \(.applicationName)"
            ],
            shortTitle: "AI에게 질문",
            systemImageName: "sparkles"
        )
    }
}
