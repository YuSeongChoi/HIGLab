import AppIntents

// MARK: - 할 일 추가 Intent

struct AddTodoIntent: AppIntent {
    // Siri가 읽어줄 제목
    static var title: LocalizedStringResource = "할 일 추가"
    
    // 단축어 앱에서 보여줄 설명
    static var description = IntentDescription("새 할 일을 추가합니다")
    
    // 실행 메서드
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // 실제 할 일 저장 로직
        TodoStore.shared.add(title: "새 할 일")
        
        // Siri 응답
        return .result(dialog: "할 일을 추가했습니다")
    }
}

// 앱 시작 시 Intent 등록
struct TodoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTodoIntent(),
            phrases: [
                "할 일 추가해줘 \(.applicationName)",
                "\(.applicationName)에 할 일 추가"
            ],
            shortTitle: "할 일 추가",
            systemImageName: "plus.circle"
        )
    }
}
