import AppIntents
import WidgetKit

// MARK: - 위젯 설정 인텐트
/// 위젯에서 표시할 할일 목록을 설정하는 인텐트
/// WidgetConfigurationIntent를 준수하여 위젯 편집에서 사용 가능
///
/// ## 사용법
/// iOS 17+에서 위젯 편집 화면에서 이 설정을 변경할 수 있습니다.
struct TodoWidgetConfigurationIntent: WidgetConfigurationIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    static var title: LocalizedStringResource = "할일 위젯 설정"
    
    /// 인텐트 설명
    static var description = IntentDescription("위젯에 표시할 할일을 설정합니다.")
    
    // MARK: - 파라미터
    
    /// 필터 설정
    @Parameter(
        title: "표시할 할일",
        description: "위젯에 표시할 할일 종류를 선택하세요",
        default: .incomplete
    )
    var filter: WidgetTodoFilter
    
    /// 정렬 기준
    @Parameter(
        title: "정렬 기준",
        description: "할일 정렬 방식을 선택하세요",
        default: .priority
    )
    var sortBy: WidgetSortOption
    
    /// 표시할 개수
    @Parameter(
        title: "표시 개수",
        description: "위젯에 표시할 할일 수",
        default: 3,
        inclusiveRange: (1, 10)
    )
    var displayCount: Int
    
    /// 우선순위 필터 (선택)
    @Parameter(
        title: "우선순위 필터",
        description: "특정 우선순위만 표시",
        default: nil
    )
    var priorityFilter: Priority?
    
    /// 특정 태그 필터 (선택)
    @Parameter(
        title: "태그 필터",
        description: "특정 태그가 있는 할일만 표시",
        default: nil
    )
    var tagFilter: Tag?
    
    // MARK: - 초기화
    
    init() {}
    
    init(
        filter: WidgetTodoFilter = .incomplete,
        sortBy: WidgetSortOption = .priority,
        displayCount: Int = 3
    ) {
        self.filter = filter
        self.sortBy = sortBy
        self.displayCount = displayCount
    }
}

// MARK: - 위젯 할일 필터
enum WidgetTodoFilter: String, AppEnum {
    case all = "all"
    case incomplete = "incomplete"
    case today = "today"
    case urgent = "urgent"
    case overdue = "overdue"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "위젯 필터")
    }
    
    static var caseDisplayRepresentations: [WidgetTodoFilter: DisplayRepresentation] {
        [
            .all: DisplayRepresentation(
                title: "전체",
                subtitle: "모든 할일 표시",
                image: .init(systemName: "list.bullet")
            ),
            .incomplete: DisplayRepresentation(
                title: "미완료",
                subtitle: "미완료 할일만 표시",
                image: .init(systemName: "circle")
            ),
            .today: DisplayRepresentation(
                title: "오늘",
                subtitle: "오늘 마감인 할일",
                image: .init(systemName: "calendar")
            ),
            .urgent: DisplayRepresentation(
                title: "긴급",
                subtitle: "긴급/높음 우선순위만",
                image: .init(systemName: "exclamationmark.circle")
            ),
            .overdue: DisplayRepresentation(
                title: "기한 지남",
                subtitle: "마감일이 지난 할일",
                image: .init(systemName: "exclamationmark.triangle")
            )
        ]
    }
}

// MARK: - 위젯 정렬 옵션
enum WidgetSortOption: String, AppEnum {
    case priority = "priority"
    case dueDate = "dueDate"
    case createdAt = "createdAt"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "정렬")
    }
    
    static var caseDisplayRepresentations: [WidgetSortOption: DisplayRepresentation] {
        [
            .priority: DisplayRepresentation(
                title: "우선순위",
                image: .init(systemName: "arrow.up.arrow.down")
            ),
            .dueDate: DisplayRepresentation(
                title: "마감일",
                image: .init(systemName: "calendar")
            ),
            .createdAt: DisplayRepresentation(
                title: "생성일",
                image: .init(systemName: "clock")
            )
        ]
    }
}

// MARK: - 위젯 데이터 제공자
/// 위젯에서 사용할 데이터를 제공하는 유틸리티
struct WidgetDataProvider {
    
    /// 설정에 따라 할일 목록 가져오기
    @MainActor
    static func getTodos(for configuration: TodoWidgetConfigurationIntent) -> [TodoItem] {
        let store = TodoStore.shared
        var todos: [TodoItem]
        
        // 필터 적용
        switch configuration.filter {
        case .all:
            todos = store.todos
        case .incomplete:
            todos = store.incompleteTodos
        case .today:
            todos = store.todayTodos
        case .urgent:
            todos = store.todos.filter { $0.priority == .urgent || $0.priority == .high }
                .filter { !$0.isCompleted }
        case .overdue:
            todos = store.overdueTodos
        }
        
        // 우선순위 필터
        if let priority = configuration.priorityFilter {
            todos = todos.filter { $0.priority == priority }
        }
        
        // 태그 필터
        if let tag = configuration.tagFilter {
            todos = todos.filter { $0.tagIds.contains(tag.id) }
        }
        
        // 정렬
        switch configuration.sortBy {
        case .priority:
            todos.sort { $0.sortPriority > $1.sortPriority }
        case .dueDate:
            todos.sort {
                guard let d1 = $0.dueDate else { return false }
                guard let d2 = $1.dueDate else { return true }
                return d1 < d2
            }
        case .createdAt:
            todos.sort { $0.createdAt > $1.createdAt }
        }
        
        // 개수 제한
        return Array(todos.prefix(configuration.displayCount))
    }
    
    /// 위젯용 요약 데이터
    @MainActor
    static func getSummary() -> WidgetSummary {
        let store = TodoStore.shared
        return WidgetSummary(
            total: store.todos.count,
            incomplete: store.incompleteTodos.count,
            today: store.todayTodos.count,
            overdue: store.overdueTodos.count,
            completionRate: store.statistics.completionRate
        )
    }
}

/// 위젯 요약 데이터
struct WidgetSummary {
    let total: Int
    let incomplete: Int
    let today: Int
    let overdue: Int
    let completionRate: Double
    
    var completionRateString: String {
        String(format: "%.0f%%", completionRate * 100)
    }
}

// MARK: - 위젯 인터랙션 인텐트
/// 위젯에서 할일을 완료 처리하는 인텐트 (버튼 탭)
struct WidgetCompleteTodoIntent: AppIntent {
    
    static var title: LocalizedStringResource = "위젯에서 할일 완료"
    
    static var description = IntentDescription("위젯에서 할일을 빠르게 완료 처리합니다.")
    
    static var openAppWhenRun: Bool = false
    
    /// 완료할 할일 ID
    @Parameter(title: "할일 ID")
    var todoId: String
    
    init() {}
    
    init(todoId: UUID) {
        self.todoId = todoId.uuidString
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: todoId) else {
            return .result()
        }
        
        _ = TodoStore.shared.complete(id: uuid)
        
        // 위젯 리로드 요청
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
        
        return .result()
    }
}

// MARK: - 위젯 할일 추가 인텐트
/// 위젯에서 빠르게 할일을 추가하는 인텐트
struct WidgetAddTodoIntent: AppIntent {
    
    static var title: LocalizedStringResource = "위젯에서 할일 추가"
    
    static var description = IntentDescription("위젯에서 빠르게 할일을 추가합니다.")
    
    static var openAppWhenRun: Bool = true
    
    /// 추가할 할일 제목
    @Parameter(title: "제목")
    var title: String
    
    init() {}
    
    init(title: String) {
        self.title = title
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            // 앱에서 추가 화면 열기
            return .result(dialog: "할일 추가 화면을 열고 있습니다...")
        }
        
        _ = TodoStore.shared.add(title: trimmed, priority: .normal)
        
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
        
        return .result(dialog: "'\(trimmed)' 할일을 추가했습니다!")
    }
}

// MARK: - 위젯 새로고침 인텐트
/// 위젯 데이터를 새로고침하는 인텐트
struct RefreshWidgetIntent: AppIntent {
    
    static var title: LocalizedStringResource = "위젯 새로고침"
    
    static var description = IntentDescription("모든 할일 위젯을 새로고침합니다.")
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        return .result(dialog: "위젯을 새로고침했습니다.")
        #else
        return .result(dialog: "위젯이 지원되지 않는 환경입니다.")
        #endif
    }
}

// MARK: - 위젯 타임라인 엔트리
/// 위젯 타임라인에서 사용하는 데이터 엔트리
struct TodoWidgetEntry {
    let date: Date
    let todos: [TodoItem]
    let summary: WidgetSummary
    let configuration: TodoWidgetConfigurationIntent
    
    /// 빈 엔트리 (플레이스홀더용)
    static var placeholder: TodoWidgetEntry {
        TodoWidgetEntry(
            date: Date(),
            todos: [
                TodoItem(title: "할일 예시 1", priority: .high),
                TodoItem(title: "할일 예시 2", priority: .normal),
                TodoItem(title: "할일 예시 3", priority: .low)
            ],
            summary: WidgetSummary(
                total: 10,
                incomplete: 5,
                today: 2,
                overdue: 1,
                completionRate: 0.5
            ),
            configuration: TodoWidgetConfigurationIntent()
        )
    }
}
