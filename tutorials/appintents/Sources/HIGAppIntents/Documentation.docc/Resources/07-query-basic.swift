import AppIntents

// 기본 EntityQuery
struct BookQuery: EntityQuery {
    // ID로 Entity 조회
    func entities(for identifiers: [BookEntity.ID]) async throws -> [BookEntity] {
        // 앱의 데이터 소스에서 조회
        let allBooks = await BookStore.shared.allBooks()
        return allBooks.filter { identifiers.contains($0.id) }
    }
}
