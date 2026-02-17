import AppIntents

struct AddBookIntent: AppIntent {
    static var title: LocalizedStringResource = "책 추가"
    
    @Parameter(title: "제목")
    var bookTitle: String
    
    @Parameter(title: "작가")
    var author: String?
    
    @Parameter(title: "카테고리")
    var category: BookCategory?
    
    // 파라미터 요약 - 단축어 UI에 표시
    static var parameterSummary: some ParameterSummary {
        // 조건부 요약
        When(\.$category, .hasAnyValue) {
            Summary("'\(\.$bookTitle)'을(를) \(\.$category)에 추가") {
                \.$author
            }
        } otherwise: {
            Summary("'\(\.$bookTitle)' 책 추가") {
                \.$author
                \.$category
            }
        }
    }
    
    func perform() async throws -> some IntentResult {
        // 책 추가 로직
        return .result(dialog: "'\(bookTitle)'을(를) 추가했습니다.")
    }
}
