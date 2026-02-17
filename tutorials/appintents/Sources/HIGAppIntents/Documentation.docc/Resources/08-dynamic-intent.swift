import AppIntents

struct FilterBooksIntent: AppIntent {
    static var title: LocalizedStringResource = "책 필터링"
    
    // DynamicOptionsProvider 연결
    @Parameter(
        title: "카테고리",
        optionsProvider: CategoryOptionsProvider()
    )
    var category: BookCategory
    
    func perform() async throws -> some IntentResult {
        let books = await BookStore.shared.books(in: category)
        return .result(
            value: books,
            dialog: "\(category) 카테고리에 \(books.count)권의 책이 있습니다."
        )
    }
}
