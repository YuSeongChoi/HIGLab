import FoundationModels

// Generable 프로토콜로 구조화된 출력 정의
@Generable
struct MovieReview {
    @Guide(description: "영화 제목")
    var title: String
    
    @Guide(description: "1-5 사이의 평점")
    var rating: Int
    
    @Guide(description: "긍정적인 점 요약")
    var pros: [String]
    
    @Guide(description: "부정적인 점 요약")
    var cons: [String]
    
    @Guide(description: "전체 한줄 요약")
    var summary: String
}

// 사용 예시
func analyzeMovie(description: String) async throws -> MovieReview {
    let session = LanguageModel.default.createSession()
    
    // Generable 타입을 제네릭으로 전달하면 구조화된 출력을 받음
    let review: MovieReview = try await session.generate(
        MovieReview.self,
        prompt: "다음 영화 설명을 분석해주세요: \(description)"
    )
    
    return review
}

// 결과 사용
// review.title → "인셉션"
// review.rating → 5
// review.pros → ["뛰어난 영상미", "독창적 스토리"]
// review.cons → ["복잡한 전개"]
// review.summary → "꿈 속의 꿈을 다룬 걸작 SF 스릴러"
