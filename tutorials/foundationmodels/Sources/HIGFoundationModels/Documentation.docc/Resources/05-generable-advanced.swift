import FoundationModels

// 중첩된 Generable 구조체
@Generable
struct RecipeAnalysis {
    @Guide(description: "요리 이름")
    var name: String
    
    @Guide(description: "예상 조리 시간 (분)")
    var cookingTime: Int
    
    @Guide(description: "난이도: easy, medium, hard")
    var difficulty: String
    
    @Guide(description: "필요한 재료 목록")
    var ingredients: [Ingredient]
    
    @Guide(description: "조리 단계")
    var steps: [CookingStep]
}

@Generable
struct Ingredient {
    @Guide(description: "재료 이름")
    var name: String
    
    @Guide(description: "필요한 양")
    var amount: String
    
    @Guide(description: "필수 재료 여부")
    var isRequired: Bool
}

@Generable
struct CookingStep {
    @Guide(description: "단계 번호")
    var stepNumber: Int
    
    @Guide(description: "설명")
    var instruction: String
    
    @Guide(description: "이 단계의 예상 시간 (분)")
    var duration: Int
}

// 복잡한 구조화 출력 사용
func analyzeRecipe(text: String) async throws -> RecipeAnalysis {
    let session = LanguageModel.default.createSession(
        systemPrompt: "당신은 요리 전문가입니다. 레시피를 분석해주세요."
    )
    
    return try await session.generate(
        RecipeAnalysis.self,
        prompt: text
    )
}

// 열거형과 함께 사용
@Generable
struct TaskAnalysis {
    @Guide(description: "작업의 우선순위")
    var priority: Priority
    
    @Guide(description: "예상 소요 시간")
    var estimatedHours: Double
}

@Generable
enum Priority: String, CaseIterable {
    case low, medium, high, urgent
}
