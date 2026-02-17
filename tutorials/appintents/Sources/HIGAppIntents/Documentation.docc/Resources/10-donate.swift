import AppIntents

class BookStore {
    static let shared = BookStore()
    
    // 책을 열람할 때 호출
    func openBook(_ book: BookEntity) async {
        // 실제 책 열기 로직
        displayBook(book)
        
        // Intent를 donate하여 시스템에 사용 기록 전달
        let intent = OpenBookIntent()
        intent.book = book
        
        try? await intent.donate()
    }
    
    // 책 검색 시
    func searchBooks(query: String) async -> [BookEntity] {
        let results = await performSearch(query)
        
        // 검색 Intent donate
        let intent = SearchBooksIntent()
        intent.query = query
        try? await intent.donate()
        
        return results
    }
    
    private func displayBook(_ book: BookEntity) {
        // 구현
    }
    
    private func performSearch(_ query: String) async -> [BookEntity] {
        // 구현
        return []
    }
}
