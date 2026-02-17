import AppIntents

struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchBooksIntent(),
            phrases: [
                // 다양한 자연어 표현 지원
                "책 검색해줘",
                "책 찾아줘",
                "\(.applicationName)에서 검색",
                "\(.applicationName) 열고 검색",
                "내 책 검색",
                "라이브러리에서 책 찾기"
            ],
            shortTitle: "책 검색",
            systemImageName: "magnifyingglass"
        )
        
        AppShortcut(
            intent: ShowReadingListIntent(),
            phrases: [
                "읽을 책 보여줘",
                "독서 목록",
                "\(.applicationName) 읽을 목록",
                "뭐 읽을까",
                "다음에 읽을 책"
            ],
            shortTitle: "독서 목록",
            systemImageName: "books.vertical"
        )
    }
}
