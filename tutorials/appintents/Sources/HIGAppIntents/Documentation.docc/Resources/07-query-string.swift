import AppIntents

// 문자열 검색 지원
struct BookQuery: EntityStringQuery {
    func entities(for identifiers: [BookEntity.ID]) async throws -> [BookEntity] {
        let allBooks = await BookStore.shared.allBooks()
        return allBooks.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [BookEntity] {
        return await BookStore.shared.recentBooks(limit: 5)
    }
    
    // 검색어로 Entity 조회
    func entities(matching string: String) async throws -> [BookEntity] {
        let allBooks = await BookStore.shared.allBooks()
        
        // 제목이나 작가에서 검색
        return allBooks.filter { book in
            book.title.localizedCaseInsensitiveContains(string) ||
            book.author.localizedCaseInsensitiveContains(string)
        }
    }
}
