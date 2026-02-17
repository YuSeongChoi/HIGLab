import AppIntents

// MARK: - 할일 검색 인텐트
/// Siri 또는 단축어를 통해 할일을 검색하는 인텐트
/// 예: "시리야, 장보기 할일 찾아줘"
///
/// ## 사용 예시
/// - "시리야, 장보기 할일 찾아줘"
/// - "시리야, 회의 관련 할일 검색해"
/// - "시리야, 할일에서 운동 찾아봐"
struct SearchTodosIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    static var title: LocalizedStringResource = "할일 검색"
    
    /// 인텐트 설명
    static var description = IntentDescription(
        "키워드로 할일을 검색합니다. 제목과 메모에서 검색합니다.",
        categoryName: "조회",
        searchKeywords: ["검색", "찾기", "search", "find", "query"]
    )
    
    /// 앱 실행 없이 처리
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 검색어
    @Parameter(
        title: "검색어",
        description: "검색할 키워드를 입력하세요",
        requestValueDialog: IntentDialog("어떤 할일을 찾을까요?")
    )
    var query: String
    
    /// 완료된 항목 포함 여부
    @Parameter(
        title: "완료된 항목 포함",
        description: "완료된 할일도 검색 결과에 포함할지 선택",
        default: false
    )
    var includeCompleted: Bool
    
    /// 최대 결과 수
    @Parameter(
        title: "최대 결과 수",
        description: "표시할 최대 검색 결과 수",
        default: 10,
        inclusiveRange: (1, 50)
    )
    var maxResults: Int
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        
        // 검색어 정리
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedQuery.isEmpty else {
            throw SearchTodoError.emptyQuery
        }
        
        // 검색 실행
        var results = store.search(query: trimmedQuery)
        
        // 완료된 항목 제외 (옵션에 따라)
        if !includeCompleted {
            results = results.filter { !$0.isCompleted }
        }
        
        // 결과 수 제한
        results = Array(results.prefix(maxResults))
        
        // 빈 결과 처리
        guard !results.isEmpty else {
            return .result(
                value: [],
                dialog: "🔍 '\(trimmedQuery)'에 해당하는 할일을 찾을 수 없습니다."
            )
        }
        
        // 결과 포맷팅
        let formatted = results.enumerated().map { index, todo in
            let status = todo.isCompleted ? "✅" : "⬜️"
            let priority = todo.priority != .normal ? " \(todo.priority.emoji)" : ""
            return "\(index + 1). \(status) \(todo.title)\(priority)"
        }.joined(separator: "\n")
        
        return .result(
            value: results,
            dialog: "🔍 '\(trimmedQuery)' 검색 결과 \(results.count)개:\n\n\(formatted)"
        )
    }
    
    // MARK: - 파라미터 요약
    
    static var parameterSummary: some ParameterSummary {
        When(\.$includeCompleted, .equalTo, true) {
            Summary("'\(\.$query)' 검색 (완료 포함, 최대 \(\.$maxResults)개)")
        } otherwise: {
            Summary("'\(\.$query)' 검색 (최대 \(\.$maxResults)개)")
        }
    }
}

// MARK: - 검색 에러
enum SearchTodoError: Error, CustomLocalizedStringResourceConvertible {
    case emptyQuery
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .emptyQuery:
            return "검색어를 입력해주세요"
        }
    }
}

// MARK: - 태그로 검색 인텐트
/// 특정 태그가 있는 할일을 검색하는 인텐트
struct SearchByTagIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    static var title: LocalizedStringResource = "태그로 검색"
    
    static var description = IntentDescription(
        "특정 태그가 있는 할일을 검색합니다.",
        categoryName: "조회"
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "태그",
        description: "검색할 태그를 선택하세요"
    )
    var tag: Tag
    
    @Parameter(
        title: "완료된 항목 포함",
        default: false
    )
    var includeCompleted: Bool
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        
        var results = store.todos(withTag: tag.id)
        
        if !includeCompleted {
            results = results.filter { !$0.isCompleted }
        }
        
        guard !results.isEmpty else {
            return .result(
                value: [],
                dialog: "🏷️ '\(tag.name)' 태그가 있는 할일이 없습니다."
            )
        }
        
        let formatted = results.enumerated().map { index, todo in
            let status = todo.isCompleted ? "✅" : "⬜️"
            return "\(index + 1). \(status) \(todo.title)"
        }.joined(separator: "\n")
        
        return .result(
            value: results,
            dialog: "🏷️ '\(tag.name)' 태그 할일 \(results.count)개:\n\n\(formatted)"
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$tag)' 태그 할일 검색")
    }
}

// MARK: - 우선순위로 검색 인텐트
/// 특정 우선순위의 할일을 검색하는 인텐트
struct SearchByPriorityIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    static var title: LocalizedStringResource = "우선순위로 검색"
    
    static var description = IntentDescription(
        "특정 우선순위의 할일을 검색합니다.",
        categoryName: "조회"
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "우선순위",
        description: "검색할 우선순위를 선택하세요"
    )
    var priority: Priority
    
    @Parameter(
        title: "완료된 항목 포함",
        default: false
    )
    var includeCompleted: Bool
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        
        var results = store.todos(with: priority)
        
        if !includeCompleted {
            results = results.filter { !$0.isCompleted }
        }
        
        guard !results.isEmpty else {
            return .result(
                value: [],
                dialog: "\(priority.emoji) \(priority.displayName) 우선순위 할일이 없습니다."
            )
        }
        
        let formatted = results.enumerated().map { index, todo in
            let status = todo.isCompleted ? "✅" : "⬜️"
            let dueInfo = todo.dueDateInfo.map { " (📅 \($0.shortDateString))" } ?? ""
            return "\(index + 1). \(status) \(todo.title)\(dueInfo)"
        }.joined(separator: "\n")
        
        return .result(
            value: results,
            dialog: "\(priority.emoji) \(priority.displayName) 우선순위 \(results.count)개:\n\n\(formatted)"
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$priority) 우선순위 할일 검색")
    }
}

// MARK: - 마감일로 검색 인텐트
/// 특정 기간 내 마감인 할일을 검색하는 인텐트
struct SearchByDueDateIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    static var title: LocalizedStringResource = "마감일로 검색"
    
    static var description = IntentDescription(
        "특정 기간 내 마감인 할일을 검색합니다.",
        categoryName: "조회"
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "기간",
        description: "검색할 기간을 선택하세요"
    )
    var period: SearchPeriod
    
    @Parameter(
        title: "완료된 항목 포함",
        default: false
    )
    var includeCompleted: Bool
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        let calendar = Calendar.current
        let now = Date()
        
        // 기간 계산
        let endDate: Date
        switch period {
        case .today:
            endDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        case .tomorrow:
            endDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 2, to: now)!)
        case .thisWeek:
            endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: now)!
        case .thisMonth:
            endDate = calendar.date(byAdding: .month, value: 1, to: now)!
        }
        
        // 필터링
        var results = store.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return dueDate <= endDate
        }
        
        if !includeCompleted {
            results = results.filter { !$0.isCompleted }
        }
        
        // 마감일 순 정렬
        results.sort { 
            guard let d1 = $0.dueDate else { return false }
            guard let d2 = $1.dueDate else { return true }
            return d1 < d2
        }
        
        guard !results.isEmpty else {
            return .result(
                value: [],
                dialog: "📅 \(period.displayName)까지 마감인 할일이 없습니다."
            )
        }
        
        let formatted = results.enumerated().map { index, todo in
            let status = todo.isCompleted ? "✅" : "⬜️"
            let dueInfo = todo.dueDateInfo.map { "(\($0.relativeString))" } ?? ""
            return "\(index + 1). \(status) \(todo.title) \(dueInfo)"
        }.joined(separator: "\n")
        
        return .result(
            value: results,
            dialog: "📅 \(period.displayName)까지 마감 \(results.count)개:\n\n\(formatted)"
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$period)까지 마감 할일 검색")
    }
}

// MARK: - 검색 기간 열거형
enum SearchPeriod: String, AppEnum {
    case today = "today"
    case tomorrow = "tomorrow"
    case thisWeek = "thisWeek"
    case thisMonth = "thisMonth"
    
    var displayName: String {
        switch self {
        case .today: return "오늘"
        case .tomorrow: return "내일"
        case .thisWeek: return "이번 주"
        case .thisMonth: return "이번 달"
        }
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "기간")
    }
    
    static var caseDisplayRepresentations: [SearchPeriod: DisplayRepresentation] {
        [
            .today: DisplayRepresentation(
                title: "오늘",
                image: .init(systemName: "sun.max")
            ),
            .tomorrow: DisplayRepresentation(
                title: "내일",
                image: .init(systemName: "sunrise")
            ),
            .thisWeek: DisplayRepresentation(
                title: "이번 주",
                image: .init(systemName: "calendar.badge.clock")
            ),
            .thisMonth: DisplayRepresentation(
                title: "이번 달",
                image: .init(systemName: "calendar")
            )
        ]
    }
}

// MARK: - 고급 검색 인텐트
/// 여러 조건을 조합한 고급 검색 인텐트
struct AdvancedSearchIntent: AppIntent {
    
    static var title: LocalizedStringResource = "고급 검색"
    
    static var description = IntentDescription(
        "여러 조건을 조합하여 할일을 검색합니다.",
        categoryName: "조회"
    )
    
    static var openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(title: "키워드", default: nil)
    var keyword: String?
    
    @Parameter(title: "우선순위", default: nil)
    var priority: Priority?
    
    @Parameter(title: "태그", default: nil)
    var tag: Tag?
    
    @Parameter(title: "완료 상태", default: nil)
    var completionStatus: CompletionStatusFilter?
    
    @Parameter(title: "최대 결과", default: 20)
    var maxResults: Int
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<[TodoItem]> {
        let store = TodoStore.shared
        var results = store.todos
        
        // 키워드 필터
        if let keyword = keyword, !keyword.isEmpty {
            results = results.filter { todo in
                todo.title.localizedCaseInsensitiveContains(keyword) ||
                (todo.notes?.localizedCaseInsensitiveContains(keyword) ?? false)
            }
        }
        
        // 우선순위 필터
        if let priority = priority {
            results = results.filter { $0.priority == priority }
        }
        
        // 태그 필터
        if let tag = tag {
            results = results.filter { $0.tagIds.contains(tag.id) }
        }
        
        // 완료 상태 필터
        if let status = completionStatus {
            switch status {
            case .completed:
                results = results.filter { $0.isCompleted }
            case .incomplete:
                results = results.filter { !$0.isCompleted }
            case .all:
                break
            }
        }
        
        // 제한
        results = Array(results.prefix(maxResults))
        
        // 조건 요약
        var conditions: [String] = []
        if let keyword = keyword, !keyword.isEmpty { conditions.append("키워드: '\(keyword)'") }
        if let priority = priority { conditions.append("우선순위: \(priority.displayName)") }
        if let tag = tag { conditions.append("태그: \(tag.name)") }
        
        let conditionSummary = conditions.isEmpty ? "전체" : conditions.joined(separator: ", ")
        
        guard !results.isEmpty else {
            return .result(
                value: [],
                dialog: "🔍 조건에 맞는 할일이 없습니다.\n조건: \(conditionSummary)"
            )
        }
        
        let formatted = results.enumerated().map { index, todo in
            let status = todo.isCompleted ? "✅" : "⬜️"
            return "\(index + 1). \(status) \(todo.title) \(todo.priority.emoji)"
        }.joined(separator: "\n")
        
        return .result(
            value: results,
            dialog: "🔍 검색 결과 \(results.count)개 (\(conditionSummary)):\n\n\(formatted)"
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("고급 검색 (최대 \(\.$maxResults)개)")
    }
}

// MARK: - 완료 상태 필터
enum CompletionStatusFilter: String, AppEnum {
    case all = "all"
    case completed = "completed"
    case incomplete = "incomplete"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "완료 상태")
    }
    
    static var caseDisplayRepresentations: [CompletionStatusFilter: DisplayRepresentation] {
        [
            .all: DisplayRepresentation(title: "전체"),
            .completed: DisplayRepresentation(title: "완료됨"),
            .incomplete: DisplayRepresentation(title: "미완료")
        ]
    }
}
