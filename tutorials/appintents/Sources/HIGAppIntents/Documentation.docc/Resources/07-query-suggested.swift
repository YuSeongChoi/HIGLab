import AppIntents

struct BookQuery: EntityQuery {
    func entities(for identifiers: [BookEntity.ID]) async throws -> [BookEntity] {
        let allBooks = await BookStore.shared.allBooks()
        return allBooks.filter { identifiers.contains($0.id) }
    }
    
    // Siri가 선택지를 보여줄 때 호출
    func suggestedEntities() async throws -> [BookEntity] {
        // 최근 읽은 책이나 자주 찾는 책을 반환
        let recentBooks = await BookStore.shared.recentBooks(limit: 5)
        return recentBooks
    }
}
