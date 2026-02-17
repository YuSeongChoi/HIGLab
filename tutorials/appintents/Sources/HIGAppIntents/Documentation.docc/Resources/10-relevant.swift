import AppIntents

struct OpenBookIntent: AppIntent {
    static var title: LocalizedStringResource = "책 열기"
    
    @Parameter(title: "책")
    var book: BookEntity
    
    func perform() async throws -> some IntentResult {
        // 책 열기 로직
        return .result()
    }
}

// RelevantIntent로 제안 시점 지정
struct OpenBookRelevantIntent: RelevantIntent {
    static var intent: OpenBookIntent.Type { OpenBookIntent.self }
    
    // 제안이 유효한 조건들
    var relevantConditions: [RelevantCondition] {
        // 시간 기반: 저녁 독서 시간
        RelevantDateCondition(
            from: DateComponents(hour: 20),
            to: DateComponents(hour: 23)
        )
        
        // 위치 기반: 집에서
        RelevantLocationCondition(
            region: .current // 또는 특정 지역
        )
    }
    
    // 관련된 Entity
    var relevantEntities: [any RelevantEntity] {
        RelevantBookEntity(book: currentlyReadingBook)
    }
}

// Spotlight에 관련성 등록
func registerRelevantIntents() async {
    let relevantIntent = OpenBookRelevantIntent()
    try? await RelevantIntentManager.shared.updateRelevantIntents([relevantIntent])
}
