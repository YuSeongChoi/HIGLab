import AppIntents

// MARK: - 할일 목록 조회 인텐트
/// Siri 또는 단축어를 통해 할일 목록을 조회하는 인텐트
/// 예: "시리야, 할일 목록 보여줘"
///
/// ## 사용 예시
/// - "시리야, 할일 목록 보여줘"
/// - "시리야, 미완료 할일 뭐 있어?"
/// - "시리야, 오늘 할일 알려줘"
struct ListTodosIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    static var title: LocalizedStringResource = "할일 목록 보기"
    
    /// 인텐트 설명
    static var description = IntentDescription(
        "현재 할일 목록을 확인합니다. 필터를 사용하여 특정 조건의 할일만 볼 수 있습니다.",
        categoryName: "조회",
        searchKeywords: ["목록", "보기", "조회", "리스트", "list", "show", "view"]
    )
    
    /// 앱 실행 없이 Siri에서 바로 응답
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 필터 옵션: 전체/미완료/완료
    @Parameter(
        title: "필터",
        description: "어떤 할일을 볼지 선택하세요",
        default: .all
    )
    var filter: TodoFilter
    
    /// 정렬 기준
    @Parameter(
        title: "정렬",
        description: "정렬 기준을 선택하세요",
        default: .priority
    )
    var sortBy: TodoSortOption
    
    /// 최대 표시 개수
    @Parameter(
        title: "최대 개수",
        description: "표시할 최대 할일 수",
        default: 10,
        inclusiveRange: (1, 50)
    )
    var limit: Int
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        
        // 필터에 따라 할일 목록 가져오기
        var todos: [TodoItem]
        switch filter {
        case .all:
            todos = store.todos
        case .incomplete:
            todos = store.incompleteTodos
        case .completed:
            todos = store.completedTodos
        case .overdue:
            todos = store.overdueTodos
        case .today:
            todos = store.todayTodos
        }
        
        // 정렬
        todos = sort(todos: todos, by: sortBy)
        
        // 제한
        if limit < todos.count {
            todos = Array(todos.prefix(limit))
        }
        
        // 빈 목록 처리
        guard !todos.isEmpty else {
            let emptyMessage = emptyMessageFor(filter: filter)
            return .result(value: [], dialog: IntentDialog(stringLiteral: emptyMessage))
        }
        
        // 목록을 읽기 좋게 포맷팅
        let formatted = formatTodoList(todos)
        
        // 결과 메시지 생성
        let countText = countTextFor(filter: filter, count: todos.count)
        let dialog = "\(countText):\n\n\(formatted)"
        
        return .result(
            value: todos,
            dialog: IntentDialog(stringLiteral: dialog)
        )
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 할일 정렬
    private func sort(todos: [TodoItem], by option: TodoSortOption) -> [TodoItem] {
        switch option {
        case .priority:
            return todos.sorted { $0.sortPriority > $1.sortPriority }
        case .dueDate:
            return todos.sorted { 
                guard let d1 = $0.dueDate else { return false }
                guard let d2 = $1.dueDate else { return true }
                return d1 < d2
            }
        case .createdAt:
            return todos.sorted { $0.createdAt > $1.createdAt }
        case .title:
            return todos.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        }
    }
    
    /// 빈 목록 메시지
    private func emptyMessageFor(filter: TodoFilter) -> String {
        switch filter {
        case .all:
            return "📝 할일이 없습니다. 새 할일을 추가해보세요!"
        case .incomplete:
            return "✅ 미완료 할일이 없습니다. 잘하셨어요!"
        case .completed:
            return "📋 완료된 할일이 없습니다."
        case .overdue:
            return "👍 기한 지난 할일이 없습니다!"
        case .today:
            return "📅 오늘 마감인 할일이 없습니다."
        }
    }
    
    /// 개수 텍스트
    private func countTextFor(filter: TodoFilter, count: Int) -> String {
        switch filter {
        case .all:
            return "총 \(count)개의 할일이 있습니다"
        case .incomplete:
            return "📋 \(count)개의 미완료 할일"
        case .completed:
            return "✅ \(count)개의 완료된 할일"
        case .overdue:
            return "⚠️ \(count)개의 기한 지난 할일"
        case .today:
            return "📅 오늘 마감인 \(count)개 할일"
        }
    }
    
    /// 할일 목록 포맷팅
    private func formatTodoList(_ todos: [TodoItem]) -> String {
        todos.enumerated().map { index, todo in
            let status = todo.isCompleted ? "✅" : "⬜️"
            let priority = todo.priority != .normal ? " \(todo.priority.emoji)" : ""
            let dueInfo = todo.dueDateInfo.map { " 📅\($0.shortDateString)" } ?? ""
            return "\(index + 1). \(status) \(todo.title)\(priority)\(dueInfo)"
        }.joined(separator: "\n")
    }
    
    // MARK: - 파라미터 요약
    
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$filter) 할일 \(\.$limit)개 보기 (\(\.$sortBy) 순)")
    }
}

// MARK: - 할일 필터 열거형
/// 할일 목록 필터링 옵션
enum TodoFilter: String, AppEnum {
    case all = "all"
    case incomplete = "incomplete"
    case completed = "completed"
    case overdue = "overdue"
    case today = "today"
    
    /// 타입 표시 이름
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "필터")
    }
    
    /// 각 케이스별 표시 정보
    static var caseDisplayRepresentations: [TodoFilter: DisplayRepresentation] {
        [
            .all: DisplayRepresentation(
                title: "전체",
                subtitle: "모든 할일",
                image: .init(systemName: "list.bullet")
            ),
            .incomplete: DisplayRepresentation(
                title: "미완료",
                subtitle: "아직 완료되지 않은 할일",
                image: .init(systemName: "circle")
            ),
            .completed: DisplayRepresentation(
                title: "완료됨",
                subtitle: "완료된 할일",
                image: .init(systemName: "checkmark.circle.fill")
            ),
            .overdue: DisplayRepresentation(
                title: "기한 지남",
                subtitle: "마감일이 지난 할일",
                image: .init(systemName: "exclamationmark.triangle")
            ),
            .today: DisplayRepresentation(
                title: "오늘",
                subtitle: "오늘 마감인 할일",
                image: .init(systemName: "calendar")
            )
        ]
    }
}

// MARK: - 정렬 옵션 열거형
/// 할일 목록 정렬 옵션
enum TodoSortOption: String, AppEnum {
    case priority = "priority"
    case dueDate = "dueDate"
    case createdAt = "createdAt"
    case title = "title"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "정렬 기준")
    }
    
    static var caseDisplayRepresentations: [TodoSortOption: DisplayRepresentation] {
        [
            .priority: DisplayRepresentation(
                title: "우선순위",
                subtitle: "중요도 순",
                image: .init(systemName: "arrow.up.arrow.down")
            ),
            .dueDate: DisplayRepresentation(
                title: "마감일",
                subtitle: "마감일 빠른 순",
                image: .init(systemName: "calendar")
            ),
            .createdAt: DisplayRepresentation(
                title: "생성일",
                subtitle: "최근 생성 순",
                image: .init(systemName: "clock")
            ),
            .title: DisplayRepresentation(
                title: "제목",
                subtitle: "가나다 순",
                image: .init(systemName: "textformat")
            )
        ]
    }
}

// MARK: - 통계 조회 인텐트
/// 할일 통계를 조회하는 인텐트
struct GetTodoStatisticsIntent: AppIntent {
    
    static var title: LocalizedStringResource = "할일 통계"
    
    static var description = IntentDescription(
        "할일 목록의 통계를 확인합니다.",
        categoryName: "조회"
    )
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let stats = TodoStore.shared.statistics
        
        var lines: [String] = []
        lines.append("📊 할일 통계")
        lines.append("───────────")
        lines.append("📋 전체: \(stats.total)개")
        lines.append("✅ 완료: \(stats.completed)개")
        lines.append("⏳ 미완료: \(stats.incomplete)개")
        
        if stats.overdue > 0 {
            lines.append("⚠️ 기한 지남: \(stats.overdue)개")
        }
        
        if stats.dueToday > 0 {
            lines.append("📅 오늘 마감: \(stats.dueToday)개")
        }
        
        if stats.highPriority > 0 {
            lines.append("🔴 높은 우선순위: \(stats.highPriority)개")
        }
        
        lines.append("───────────")
        lines.append("📈 완료율: \(stats.completionRateString)")
        
        return .result(dialog: IntentDialog(stringLiteral: lines.joined(separator: "\n")))
    }
}

// MARK: - 오늘 할일 조회 인텐트
/// 오늘 마감인 할일만 조회하는 간편 인텐트
struct GetTodayTodosIntent: AppIntent {
    
    static var title: LocalizedStringResource = "오늘 할일"
    
    static var description = IntentDescription(
        "오늘 마감인 할일을 확인합니다.",
        categoryName: "조회"
    )
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        let todayTodos = store.todayTodos
        
        guard !todayTodos.isEmpty else {
            return .result(
                value: [],
                dialog: "📅 오늘 마감인 할일이 없습니다. 여유로운 하루 보내세요! ☀️"
            )
        }
        
        let incomplete = todayTodos.filter { !$0.isCompleted }
        let completed = todayTodos.filter { $0.isCompleted }
        
        var message = "📅 오늘 할일 \(todayTodos.count)개"
        
        if !incomplete.isEmpty {
            message += "\n\n⏳ 미완료 (\(incomplete.count)개):\n"
            message += incomplete.enumerated().map { index, todo in
                "  \(index + 1). \(todo.title) \(todo.priority.emoji)"
            }.joined(separator: "\n")
        }
        
        if !completed.isEmpty {
            message += "\n\n✅ 완료 (\(completed.count)개):\n"
            message += completed.enumerated().map { index, todo in
                "  \(index + 1). \(todo.title)"
            }.joined(separator: "\n")
        }
        
        return .result(
            value: todayTodos,
            dialog: IntentDialog(stringLiteral: message)
        )
    }
}

// MARK: - 긴급 할일 조회 인텐트
/// 긴급/높은 우선순위 할일을 조회하는 인텐트
struct GetUrgentTodosIntent: AppIntent {
    
    static var title: LocalizedStringResource = "긴급 할일"
    
    static var description = IntentDescription(
        "긴급하거나 높은 우선순위의 할일을 확인합니다.",
        categoryName: "조회"
    )
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        let urgentTodos = (store.todos(with: .urgent) + store.todos(with: .high))
            .filter { !$0.isCompleted }
            .sorted { $0.priority > $1.priority }
        
        guard !urgentTodos.isEmpty else {
            return .result(
                value: [],
                dialog: "🟢 긴급한 할일이 없습니다!"
            )
        }
        
        let message = urgentTodos.enumerated().map { index, todo in
            "\(index + 1). \(todo.priority.emoji) \(todo.title)"
        }.joined(separator: "\n")
        
        return .result(
            value: urgentTodos,
            dialog: "🔴 긴급/높음 우선순위 \(urgentTodos.count)개:\n\n\(message)"
        )
    }
}
