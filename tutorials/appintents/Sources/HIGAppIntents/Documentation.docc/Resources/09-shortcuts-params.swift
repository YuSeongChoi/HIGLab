import AppIntents

struct SearchBooksIntent: AppIntent {
    static var title: LocalizedStringResource = "책 검색"
    
    @Parameter(title: "검색어")
    var query: String?
    
    func perform() async throws -> some IntentResult {
        // 검색 로직
        return .result()
    }
}

struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchBooksIntent(),
            phrases: [
                // 파라미터 없이
                "책 검색",
                
                // 파라미터 포함 - 문자열 보간법 사용
                "\(\.$query) 검색해줘",
                "\(\.$query) 책 찾아줘",
                "\(.applicationName)에서 \(\.$query) 검색"
            ],
            shortTitle: "책 검색",
            systemImageName: "magnifyingglass"
        )
    }
}
