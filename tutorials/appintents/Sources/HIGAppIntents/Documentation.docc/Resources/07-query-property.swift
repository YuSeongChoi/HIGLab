import AppIntents

// 속성 기반 필터링 지원
struct BookQuery: EntityPropertyQuery {
    func entities(for identifiers: [BookEntity.ID]) async throws -> [BookEntity] {
        let allBooks = await BookStore.shared.allBooks()
        return allBooks.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [BookEntity] {
        return await BookStore.shared.recentBooks(limit: 5)
    }
    
    // 정렬 옵션
    static var sortingOptions = SortingOptions {
        SortableBy(\BookEntity.$title)
        SortableBy(\BookEntity.$author)
        SortableBy(\BookEntity.$publishDate)
    }
    
    // 속성 기반 필터 조회
    static var properties = EntityQueryProperties {
        Property(\BookEntity.$author) {
            EqualToComparator { $0 }
            ContainsComparator { $0 }
        }
        Property(\BookEntity.$isRead) {
            EqualToComparator { $0 }
        }
        Property(\BookEntity.$pageCount) {
            LessThanComparator { $0 }
            GreaterThanComparator { $0 }
        }
    }
    
    func entities(
        matching comparators: [EntityQueryComparator<BookEntity>],
        mode: ComparatorMode,
        sortedBy: [EntityQuerySort<BookEntity>],
        limit: Int?
    ) async throws -> [BookEntity] {
        // 필터 및 정렬 로직 구현
        var books = await BookStore.shared.allBooks()
        
        // comparators로 필터링
        // sortedBy로 정렬
        // limit로 개수 제한
        
        return books
    }
}
