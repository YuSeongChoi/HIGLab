import FoundationModels

// Tool 정의
@Tool
struct WeatherTool {
    static let description = "현재 날씨를 조회합니다"
    
    @Parameter(description: "도시 이름")
    var city: String
    
    func execute() async -> String {
        // 실제로는 API 호출
        return "\(city)의 현재 날씨: 맑음, 23°C"
    }
}

@Tool
struct CalculatorTool {
    static let description = "수학 계산을 수행합니다"
    
    @Parameter(description: "계산식")
    var expression: String
    
    func execute() async -> String {
        // 간단한 계산기 구현
        return "결과: 42"
    }
}

// Tool을 모델에 연결
func createModelWithTools() -> LanguageModel.Session {
    let session = LanguageModel.default.createSession(
        tools: [WeatherTool.self, CalculatorTool.self]
    )
    return session
}

// 사용 예시
// "서울 날씨 어때?" → 모델이 WeatherTool 호출 결정
// → WeatherTool.execute() 실행
// → 결과를 자연어로 변환해 응답
