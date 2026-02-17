import AppIntents

// 검색 가능한 동적 옵션
struct SearchableBookProvider: DynamicOptionsProvider {
    @IntentParameterDependency<SelectBookIntent>(\.$category)
    var intent
    
    // 검색어 없을 때 기본 결과
    func results() async throws -> [BookEntity] {
        guard let category = intent?.category else {
            return await BookStore.shared.recentBooks(limit: 10)
        }
        return await BookStore.shared.books(in: category)
    }
    
    // 검색어로 필터링
    func results(matching query: String) async throws -> [BookEntity] {
        let allBooks: [BookEntity]
        
        if let category = intent?.category {
            allBooks = await BookStore.shared.books(in: category)
        } else {
            allBooks = await BookStore.shared.allBooks()
        }
        
        // 제목이나 작가명으로 검색
        return allBooks.filter { book in
            book.title.localizedCaseInsensitiveContains(query) ||
            book.author.localizedCaseInsensitiveContains(query)
        }
    }
    
    // 기본 검색어 (선택 사항)
    static var defaultQuery: String? { nil }
}
