import AppIntents

// MARK: - 단축어 통합

struct TodoShortcutsProvider: AppShortcutsProvider {
    
    // 단축어 앱에 노출할 Intent들
    static var appShortcuts: [AppShortcut] {
        
        // 할 일 추가 단축어
        AppShortcut(
            intent: AddTodoIntent(),
            phrases: [
                "할 일 추가 \(.applicationName)",
                "\(.applicationName) 새 할 일",
                "투두 추가해줘"
            ],
            shortTitle: "할 일 추가",
            systemImageName: "plus.circle.fill"
        )
        
        // 할 일 목록 보기
        AppShortcut(
            intent: ShowTodosIntent(),
            phrases: [
                "할 일 보여줘 \(.applicationName)",
                "\(.applicationName) 오늘 할 일",
                "내 투두 리스트"
            ],
            shortTitle: "할 일 목록",
            systemImageName: "list.bullet"
        )
        
        // 완료한 할 일 삭제
        AppShortcut(
            intent: ClearCompletedIntent(),
            phrases: [
                "완료한 할 일 정리 \(.applicationName)"
            ],
            shortTitle: "완료 항목 정리",
            systemImageName: "checkmark.circle"
        )
    }
}

// Siri에게 바로 말하면 실행됨:
// "할 일 추가해줘" → AddTodoIntent 실행
// "내 투두 리스트 보여줘" → ShowTodosIntent 실행
