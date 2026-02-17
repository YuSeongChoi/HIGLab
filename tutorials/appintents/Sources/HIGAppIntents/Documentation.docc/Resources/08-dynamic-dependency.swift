import AppIntents

// 다른 파라미터에 의존하는 옵션 제공자
struct BookOptionsProvider: DynamicOptionsProvider {
    // 선택된 카테고리를 주입받음
    @IntentParameterDependency<FilterBooksIntent>(
        \.$category
    )
    var intent
    
    func results() async throws -> [BookEntity] {
        // 선택된 카테고리가 없으면 빈 배열
        guard let category = intent?.category else {
            return []
        }
        
        // 해당 카테고리의 책만 반환
        return await BookStore.shared.books(in: category)
    }
}
