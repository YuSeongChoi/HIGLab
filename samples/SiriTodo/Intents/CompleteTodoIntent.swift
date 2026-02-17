import AppIntents

// MARK: - 할일 완료 인텐트
/// Siri 또는 단축어를 통해 할일을 완료 처리하는 인텐트
/// 예: "시리야, 장보기 할일 완료해줘"
struct CompleteTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    static var title: LocalizedStringResource = "할일 완료"
    
    /// 인텐트 설명
    static var description = IntentDescription("선택한 할일을 완료 처리합니다")
    
    /// 앱 실행 없이 처리
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 완료할 할일 항목
    @Parameter(title: "할일", description: "완료 처리할 할일을 선택하세요")
    var todo: TodoItem
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // 이미 완료된 경우
        if todo.isCompleted {
            return .result(dialog: "\"\(todo.title)\"은(는) 이미 완료되었습니다")
        }
        
        // 할일 완료 처리
        TodoStore.shared.complete(todo)
        
        // 성공 메시지
        return .result(dialog: "\"\(todo.title)\" 완료! 잘하셨어요 👏")
    }
    
    // MARK: - 파라미터 요약
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 완료하기")
    }
}

// MARK: - 다음 할일 완료 인텐트
/// 가장 오래된 미완료 할일을 완료 처리하는 간편 인텐트
/// 예: "시리야, 다음 할일 완료"
struct CompleteNextTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    static var title: LocalizedStringResource = "다음 할일 완료"
    
    static var description = IntentDescription("가장 오래된 미완료 할일을 완료 처리합니다")
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = TodoStore.shared
        
        // 미완료 할일 중 가장 오래된 것 찾기
        guard let nextTodo = store.incompleteTodos.first else {
            return .result(dialog: "완료할 할일이 없습니다. 모두 끝났어요! 🎉")
        }
        
        // 완료 처리
        store.complete(nextTodo)
        
        // 남은 할일 수 확인
        let remaining = store.incompleteTodos.count
        let remainingText = remaining > 0 
            ? "\(remaining)개의 할일이 남았습니다" 
            : "모든 할일을 완료했어요!"
        
        return .result(
            dialog: "\"\(nextTodo.title)\" 완료! \(remainingText)"
        )
    }
}
