import AppIntents

// MARK: - 할일 목록 조회 인텐트
/// Siri 또는 단축어를 통해 할일 목록을 조회하는 인텐트
/// 예: "시리야, 할일 목록 보여줘"
struct ListTodosIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    static var title: LocalizedStringResource = "할일 목록 보기"
    
    /// 인텐트 설명
    static var description = IntentDescription("현재 할일 목록을 확인합니다")
    
    /// 앱 실행 없이 Siri에서 바로 응답
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 필터 옵션: 전체/미완료/완료
    @Parameter(title: "필터", default: .all)
    var filter: TodoFilter
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        
        // 필터에 따라 할일 목록 가져오기
        let todos: [TodoItem]
        switch filter {
        case .all:
            todos = store.todos
        case .incomplete:
            todos = store.incompleteTodos
        case .completed:
            todos = store.completedTodos
        }
        
        // 빈 목록 처리
        guard !todos.isEmpty else {
            let emptyMessage: String
            switch filter {
            case .all:
                emptyMessage = "할일이 없습니다"
            case .incomplete:
                emptyMessage = "미완료 할일이 없습니다"
            case .completed:
                emptyMessage = "완료된 할일이 없습니다"
            }
            return .result(value: [], dialog: "\(emptyMessage)")
        }
        
        // 목록을 읽기 좋게 포맷팅
        let formatted = todos.enumerated().map { index, todo in
            let status = todo.isCompleted ? "✓" : "○"
            return "\(index + 1). \(status) \(todo.title)"
        }.joined(separator: "\n")
        
        // 결과 메시지 생성
        let countText: String
        switch filter {
        case .all:
            countText = "총 \(todos.count)개의 할일"
        case .incomplete:
            countText = "\(todos.count)개의 미완료 할일"
        case .completed:
            countText = "\(todos.count)개의 완료된 할일"
        }
        
        return .result(
            value: todos,
            dialog: "\(countText)이 있습니다:\n\(formatted)"
        )
    }
    
    // MARK: - 파라미터 요약
    
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$filter) 할일 보기")
    }
}

// MARK: - 할일 필터 열거형
/// 할일 목록 필터링 옵션
enum TodoFilter: String, AppEnum {
    case all = "all"
    case incomplete = "incomplete"
    case completed = "completed"
    
    /// 타입 표시 이름
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "필터")
    }
    
    /// 각 케이스별 표시 정보
    static var caseDisplayRepresentations: [TodoFilter: DisplayRepresentation] {
        [
            .all: DisplayRepresentation(title: "전체"),
            .incomplete: DisplayRepresentation(title: "미완료"),
            .completed: DisplayRepresentation(title: "완료됨")
        ]
    }
}
