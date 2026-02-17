import AppIntents

struct SearchBooksIntent: AppIntent {
    static var title: LocalizedStringResource = "책 검색"
    
    @Parameter(title: "검색어")
    var query: String
    
    // 다양한 결과 타입 반환
    func perform() async throws -> some IntentResult & ReturnsValue<[BookEntity]> & ProvidesDialog {
        let results = await BookStore.shared.search(query)
        
        if results.isEmpty {
            return .result(
                value: [],
                dialog: "'\(query)'에 대한 검색 결과가 없습니다."
            )
        }
        
        return .result(
            value: results,
            dialog: "\(results.count)권의 책을 찾았습니다."
        )
    }
}
