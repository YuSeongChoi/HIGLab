import AppIntents

struct SelectBookIntent: AppIntent {
    static var title: LocalizedStringResource = "책 선택"
    
    @Parameter(title: "카테고리")
    var category: BookCategory
    
    // 카테고리 선택 후 해당 카테고리 책만 표시
    @Parameter(
        title: "책",
        optionsProvider: BookOptionsProvider()
    )
    var book: BookEntity
    
    func perform() async throws -> some IntentResult {
        return .result(
            dialog: "'\(book.title)'을(를) 선택했습니다."
        )
    }
}

struct BookOptionsProvider: DynamicOptionsProvider {
    @IntentParameterDependency<SelectBookIntent>(\.$category)
    var intent
    
    func results() async throws -> [BookEntity] {
        guard let category = intent?.category else {
            // 카테고리 미선택 시 전체 반환
            return await BookStore.shared.allBooks()
        }
        return await BookStore.shared.books(in: category)
    }
}
