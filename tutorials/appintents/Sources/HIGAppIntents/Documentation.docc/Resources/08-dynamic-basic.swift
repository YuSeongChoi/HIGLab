import AppIntents

// 카테고리 열거형
enum BookCategory: String, AppEnum {
    case fiction = "fiction"
    case nonFiction = "non_fiction"
    case science = "science"
    case history = "history"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "카테고리")
    static var caseDisplayRepresentations: [BookCategory: DisplayRepresentation] = [
        .fiction: "소설",
        .nonFiction: "비소설",
        .science: "과학",
        .history: "역사"
    ]
}

// 동적 옵션 제공자
struct CategoryOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [BookCategory] {
        // 사용자의 라이브러리에 있는 카테고리만 반환
        let categories = await BookStore.shared.availableCategories()
        return categories
    }
}
