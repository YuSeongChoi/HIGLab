import AppIntents

// MARK: - 우선순위 설정 인텐트
/// Siri 또는 단축어를 통해 할일의 우선순위를 변경하는 인텐트
/// 예: "시리야, 장보기 할일 긴급으로 바꿔줘"
///
/// ## 사용 예시
/// - "시리야, 장보기 우선순위 높음으로 설정해"
/// - "시리야, 회의 할일 긴급으로 바꿔"
struct SetPriorityIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    static var title: LocalizedStringResource = "우선순위 설정"
    
    /// 인텐트 설명
    static var description = IntentDescription(
        "할일의 우선순위를 변경합니다.",
        categoryName: "관리",
        searchKeywords: ["우선순위", "중요도", "priority", "importance"]
    )
    
    /// 앱 실행 없이 처리
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 대상 할일
    @Parameter(
        title: "할일",
        description: "우선순위를 변경할 할일을 선택하세요",
        requestValueDialog: IntentDialog("어떤 할일의 우선순위를 변경할까요?")
    )
    var todo: TodoItem
    
    /// 새 우선순위
    @Parameter(
        title: "우선순위",
        description: "설정할 우선순위를 선택하세요",
        requestValueDialog: IntentDialog("어떤 우선순위로 설정할까요?")
    )
    var priority: Priority
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        let store = TodoStore.shared
        
        // 이미 같은 우선순위인 경우
        if todo.priority == priority {
            return .result(
                value: todo,
                dialog: "\"\(todo.title)\"은(는) 이미 \(priority.displayName) 우선순위입니다."
            )
        }
        
        // 이전 우선순위 저장
        let oldPriority = todo.priority
        
        // 우선순위 변경
        guard let updatedTodo = store.setPriority(id: todo.id, priority: priority) else {
            throw SetPriorityError.todoNotFound
        }
        
        return .result(
            value: updatedTodo,
            dialog: "\(priority.emoji) \"\(todo.title)\" 우선순위를 \(oldPriority.displayName)에서 \(priority.displayName)(으)로 변경했습니다."
        )
    }
    
    // MARK: - 파라미터 요약
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 우선순위를 \(\.$priority)(으)로 설정")
    }
}

// MARK: - 우선순위 에러
enum SetPriorityError: Error, CustomLocalizedStringResourceConvertible {
    case todoNotFound
    case invalidPriority
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .todoNotFound:
            return "해당 할일을 찾을 수 없습니다"
        case .invalidPriority:
            return "유효하지 않은 우선순위입니다"
        }
    }
}

// MARK: - 긴급으로 설정 인텐트
/// 할일을 긴급 우선순위로 빠르게 설정하는 간편 인텐트
struct SetUrgentIntent: AppIntent {
    
    static var title: LocalizedStringResource = "긴급으로 설정"
    
    static var description = IntentDescription(
        "할일을 긴급 우선순위로 설정합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(
        title: "할일",
        description: "긴급으로 설정할 할일을 선택하세요"
    )
    var todo: TodoItem
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        let store = TodoStore.shared
        
        if todo.priority == .urgent {
            return .result(
                value: todo,
                dialog: "\"\(todo.title)\"은(는) 이미 긴급 우선순위입니다."
            )
        }
        
        guard let updatedTodo = store.setPriority(id: todo.id, priority: .urgent) else {
            throw SetPriorityError.todoNotFound
        }
        
        return .result(
            value: updatedTodo,
            dialog: "🔴 \"\(todo.title)\"을(를) 긴급 우선순위로 설정했습니다!"
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 긴급으로 설정")
    }
}

// MARK: - 높음으로 설정 인텐트
struct SetHighPriorityIntent: AppIntent {
    
    static var title: LocalizedStringResource = "높은 우선순위로 설정"
    
    static var description = IntentDescription(
        "할일을 높은 우선순위로 설정합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "할일")
    var todo: TodoItem
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        guard let updatedTodo = TodoStore.shared.setPriority(id: todo.id, priority: .high) else {
            throw SetPriorityError.todoNotFound
        }
        
        return .result(
            value: updatedTodo,
            dialog: "🟠 \"\(todo.title)\"을(를) 높은 우선순위로 설정했습니다."
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 높은 우선순위로 설정")
    }
}

// MARK: - 마감일 설정 인텐트
/// 할일의 마감일을 설정하는 인텐트
struct SetDueDateIntent: AppIntent {
    
    static var title: LocalizedStringResource = "마감일 설정"
    
    static var description = IntentDescription(
        "할일의 마감일을 설정합니다.",
        categoryName: "관리",
        searchKeywords: ["마감일", "기한", "deadline", "due date"]
    )
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(
        title: "할일",
        description: "마감일을 설정할 할일을 선택하세요"
    )
    var todo: TodoItem
    
    @Parameter(
        title: "마감일",
        description: "설정할 마감일을 선택하세요"
    )
    var dueDate: DueDatePreset
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        let store = TodoStore.shared
        
        guard let updatedTodo = store.setDueDate(id: todo.id, dueDate: dueDate.date) else {
            throw SetDueDateError.todoNotFound
        }
        
        if dueDate == .none {
            return .result(
                value: updatedTodo,
                dialog: "📅 \"\(todo.title)\"의 마감일을 제거했습니다."
            )
        }
        
        let dueDateInfo = updatedTodo.dueDateInfo!
        return .result(
            value: updatedTodo,
            dialog: "📅 \"\(todo.title)\"의 마감일을 \(dueDateInfo.dateString)(으)로 설정했습니다."
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 마감일을 \(\.$dueDate)(으)로 설정")
    }
}

// MARK: - 마감일 에러
enum SetDueDateError: Error, CustomLocalizedStringResourceConvertible {
    case todoNotFound
    case invalidDate
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .todoNotFound:
            return "해당 할일을 찾을 수 없습니다"
        case .invalidDate:
            return "유효하지 않은 날짜입니다"
        }
    }
}

// MARK: - 오늘 마감으로 설정 인텐트
struct SetDueTodayIntent: AppIntent {
    
    static var title: LocalizedStringResource = "오늘 마감으로 설정"
    
    static var description = IntentDescription(
        "할일의 마감일을 오늘로 설정합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "할일")
    var todo: TodoItem
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        guard let updatedTodo = TodoStore.shared.setDueDate(id: todo.id, dueDate: DueDate.today.date) else {
            throw SetDueDateError.todoNotFound
        }
        
        return .result(
            value: updatedTodo,
            dialog: "📅 \"\(todo.title)\"의 마감일을 오늘로 설정했습니다."
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 오늘 마감으로 설정")
    }
}

// MARK: - 태그 추가 인텐트
struct AddTagToTodoIntent: AppIntent {
    
    static var title: LocalizedStringResource = "할일에 태그 추가"
    
    static var description = IntentDescription(
        "할일에 태그를 추가합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "할일")
    var todo: TodoItem
    
    @Parameter(title: "태그")
    var tag: Tag
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        guard let updatedTodo = TodoStore.shared.addTag(id: todo.id, tagId: tag.id) else {
            throw TagError.todoNotFound
        }
        
        return .result(
            value: updatedTodo,
            dialog: "🏷️ \"\(todo.title)\"에 '\(tag.name)' 태그를 추가했습니다."
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)'에 '\(\.$tag)' 태그 추가")
    }
}

// MARK: - 태그 제거 인텐트
struct RemoveTagFromTodoIntent: AppIntent {
    
    static var title: LocalizedStringResource = "할일에서 태그 제거"
    
    static var description = IntentDescription(
        "할일에서 태그를 제거합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "할일")
    var todo: TodoItem
    
    @Parameter(title: "태그")
    var tag: Tag
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        guard let updatedTodo = TodoStore.shared.removeTag(id: todo.id, tagId: tag.id) else {
            throw TagError.todoNotFound
        }
        
        return .result(
            value: updatedTodo,
            dialog: "🏷️ \"\(todo.title)\"에서 '\(tag.name)' 태그를 제거했습니다."
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)'에서 '\(\.$tag)' 태그 제거")
    }
}

// MARK: - 태그 에러
enum TagError: Error, CustomLocalizedStringResourceConvertible {
    case todoNotFound
    case tagNotFound
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .todoNotFound:
            return "해당 할일을 찾을 수 없습니다"
        case .tagNotFound:
            return "해당 태그를 찾을 수 없습니다"
        }
    }
}
