import AppIntents

// MARK: - 할일 추가 인텐트
/// Siri 또는 단축어를 통해 새 할일을 추가하는 인텐트
/// 예: "시리야, 할일에 장보기 추가해줘"
struct AddTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목 (단축어 앱에 표시)
    static var title: LocalizedStringResource = "할일 추가"
    
    /// 인텐트 설명
    static var description = IntentDescription("새로운 할일을 목록에 추가합니다")
    
    /// Siri 대화 중 바로 실행 허용
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 추가할 할일 제목
    @Parameter(title: "할일 제목", description: "추가할 할일의 내용")
    var title: String
    
    // MARK: - 실행
    
    /// 인텐트 실행
    /// - Returns: 추가된 할일 정보와 결과 메시지
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        // 빈 제목 검증
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw AddTodoError.emptyTitle
        }
        
        // 할일 추가
        let newTodo = TodoStore.shared.add(title: trimmed)
        
        // 결과 반환
        return .result(
            value: newTodo,
            dialog: "\"\(trimmed)\" 할일을 추가했습니다"
        )
    }
    
    // MARK: - 파라미터 요약 (단축어 앱 표시용)
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$title)' 할일 추가")
    }
}

// MARK: - 에러 정의
enum AddTodoError: Error, CustomLocalizedStringResourceConvertible {
    case emptyTitle
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .emptyTitle:
            return "할일 제목을 입력해주세요"
        }
    }
}
