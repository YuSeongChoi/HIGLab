import AppIntents

// MARK: - 할일 완료 인텐트
/// Siri 또는 단축어를 통해 할일을 완료 처리하는 인텐트
/// 예: "시리야, 장보기 할일 완료해줘"
///
/// ## 사용 예시
/// - "시리야, 장보기 완료해줘"
/// - "시리야, 할일 체크해줘"
struct CompleteTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    static var title: LocalizedStringResource = "할일 완료"
    
    /// 인텐트 설명
    static var description = IntentDescription(
        "선택한 할일을 완료 처리합니다.",
        categoryName: "관리",
        searchKeywords: ["완료", "체크", "끝", "done", "complete", "finish"]
    )
    
    /// 앱 실행 없이 처리
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 완료할 할일 항목
    @Parameter(
        title: "할일",
        description: "완료 처리할 할일을 선택하세요",
        requestValueDialog: IntentDialog("어떤 할일을 완료할까요?")
    )
    var todo: TodoItem
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        // 이미 완료된 경우
        if todo.isCompleted {
            return .result(
                value: todo,
                dialog: "\"\(todo.title)\"은(는) 이미 완료되었습니다 ✅"
            )
        }
        
        // 할일 완료 처리
        TodoStore.shared.complete(todo)
        
        // 남은 할일 수 확인
        let remaining = TodoStore.shared.incompleteTodos.count
        let remainingText = remaining > 0 
            ? "\(remaining)개의 할일이 남았습니다." 
            : "오늘의 모든 할일을 완료했어요! 🎉"
        
        // 업데이트된 항목 가져오기
        let updatedTodo = TodoStore.shared.find(id: todo.id) ?? todo
        
        // 성공 메시지
        return .result(
            value: updatedTodo,
            dialog: "\"\(todo.title)\" 완료! 👏 \(remainingText)"
        )
    }
    
    // MARK: - 파라미터 요약
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 완료하기")
    }
}

// MARK: - 다음 할일 완료 인텐트
/// 가장 중요한 미완료 할일을 완료 처리하는 간편 인텐트
/// 예: "시리야, 다음 할일 완료"
struct CompleteNextTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    static var title: LocalizedStringResource = "다음 할일 완료"
    
    static var description = IntentDescription(
        "가장 중요한 미완료 할일을 완료 처리합니다. 우선순위와 마감일을 고려합니다.",
        categoryName: "관리",
        searchKeywords: ["다음", "하나", "next", "one"]
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem?> {
        let store = TodoStore.shared
        
        // 가장 중요한 미완료 할일 찾기 (우선순위/마감일 고려)
        guard let nextTodo = store.sortedIncompleteTodos.first else {
            return .result(
                value: nil,
                dialog: "완료할 할일이 없습니다. 모두 끝났어요! 🎉"
            )
        }
        
        // 완료 처리
        store.complete(nextTodo)
        
        // 업데이트된 항목
        let updatedTodo = store.find(id: nextTodo.id)
        
        // 남은 할일 수 확인
        let remaining = store.incompleteTodos.count
        let remainingText: String
        
        if remaining == 0 {
            remainingText = "모든 할일을 완료했어요! 🎉"
        } else if remaining == 1 {
            remainingText = "마지막 1개 남았어요!"
        } else {
            remainingText = "\(remaining)개의 할일이 남았습니다."
        }
        
        return .result(
            value: updatedTodo,
            dialog: "\"\(nextTodo.title)\" 완료! \(remainingText)"
        )
    }
}

// MARK: - 모든 할일 완료 인텐트
/// 모든 미완료 할일을 완료 처리하는 인텐트
/// 확인 대화를 통해 실수 방지
struct CompleteAllTodosIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    static var title: LocalizedStringResource = "모든 할일 완료"
    
    static var description = IntentDescription(
        "모든 미완료 할일을 한 번에 완료 처리합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - 확인 대화
    
    @Parameter(
        title: "확인",
        description: "정말 모든 할일을 완료할까요?",
        default: false
    )
    var confirmed: Bool
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = TodoStore.shared
        let incompleteTodos = store.incompleteTodos
        
        // 미완료 할일이 없는 경우
        guard !incompleteTodos.isEmpty else {
            return .result(dialog: "완료할 할일이 없습니다.")
        }
        
        // 확인되지 않은 경우 확인 요청
        if !confirmed {
            throw CompleteAllError.needsConfirmation(count: incompleteTodos.count)
        }
        
        // 모든 할일 완료 처리
        var completedCount = 0
        for todo in incompleteTodos {
            store.complete(todo)
            completedCount += 1
        }
        
        return .result(dialog: "\(completedCount)개의 할일을 모두 완료했습니다! 🎉")
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("모든 할일 완료하기")
    }
}

// MARK: - 할일 미완료로 되돌리기 인텐트
/// 완료된 할일을 미완료 상태로 되돌리는 인텐트
struct UncompleteTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    static var title: LocalizedStringResource = "할일 되돌리기"
    
    static var description = IntentDescription(
        "완료된 할일을 미완료 상태로 되돌립니다.",
        categoryName: "관리",
        searchKeywords: ["되돌리기", "취소", "undo", "revert"]
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "할일",
        description: "되돌릴 할일을 선택하세요"
    )
    var todo: TodoItem
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem?> {
        // 이미 미완료 상태인 경우
        if !todo.isCompleted {
            return .result(
                value: todo,
                dialog: "\"\(todo.title)\"은(는) 아직 완료되지 않았습니다."
            )
        }
        
        // 미완료로 되돌리기
        let updatedTodo = TodoStore.shared.uncomplete(id: todo.id)
        
        return .result(
            value: updatedTodo,
            dialog: "\"\(todo.title)\"을(를) 미완료 상태로 되돌렸습니다."
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 되돌리기")
    }
}

// MARK: - 에러 정의
enum CompleteAllError: Error, CustomLocalizedStringResourceConvertible {
    case needsConfirmation(count: Int)
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .needsConfirmation(let count):
            return "\(count)개의 할일을 모두 완료하시겠습니까? confirmed를 true로 설정하세요."
        }
    }
}

// MARK: - 특정 우선순위 할일 완료 인텐트
/// 특정 우선순위의 모든 할일을 완료하는 인텐트
struct CompleteTodosByPriorityIntent: AppIntent {
    
    static var title: LocalizedStringResource = "우선순위별 할일 완료"
    
    static var description = IntentDescription(
        "특정 우선순위의 모든 할일을 완료합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "우선순위")
    var priority: Priority
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = TodoStore.shared
        let todos = store.todos(with: priority).filter { !$0.isCompleted }
        
        guard !todos.isEmpty else {
            return .result(dialog: "\(priority.displayName) 우선순위의 미완료 할일이 없습니다.")
        }
        
        for todo in todos {
            store.complete(todo)
        }
        
        return .result(
            dialog: "\(priority.displayName) 우선순위 \(todos.count)개 할일 완료! \(priority.emoji)"
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$priority) 우선순위 할일 모두 완료")
    }
}

// MARK: - 오늘 할일 완료 인텐트
/// 오늘 마감인 모든 할일을 완료하는 인텐트
struct CompleteTodayTodosIntent: AppIntent {
    
    static var title: LocalizedStringResource = "오늘 할일 모두 완료"
    
    static var description = IntentDescription(
        "오늘 마감인 모든 할일을 완료합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = TodoStore.shared
        let todayTodos = store.todayTodos.filter { !$0.isCompleted }
        
        guard !todayTodos.isEmpty else {
            return .result(dialog: "오늘 마감인 미완료 할일이 없습니다. 👍")
        }
        
        for todo in todayTodos {
            store.complete(todo)
        }
        
        return .result(
            dialog: "오늘의 \(todayTodos.count)개 할일 모두 완료! 🌟"
        )
    }
}
