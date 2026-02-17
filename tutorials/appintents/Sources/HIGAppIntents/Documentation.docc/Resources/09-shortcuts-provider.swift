import AppIntents

struct MyAppShortcuts: AppShortcutsProvider {
    // 앱에서 제공하는 단축어 목록
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchBooksIntent(),
            phrases: [
                "책 검색",
                "\(.applicationName)에서 검색"
            ],
            shortTitle: "책 검색",
            systemImageName: "magnifyingglass"
        )
        
        AppShortcut(
            intent: AddBookIntent(),
            phrases: [
                "책 추가",
                "\(.applicationName)에 책 추가"
            ],
            shortTitle: "책 추가",
            systemImageName: "plus.circle"
        )
    }
}
