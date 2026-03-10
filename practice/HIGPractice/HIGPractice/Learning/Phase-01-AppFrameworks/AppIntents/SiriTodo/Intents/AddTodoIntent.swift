// 이 파일은 "할일 생성" 관련 App Intent를 모아둔 파일이다.
// 구성:
// - AddTodoIntent: 일반적인 할일 추가
// - QuickAddTodoIntent: 제목만 받아 빠르게 추가
// - AddTodayTodoIntent: 오늘 마감 할일 추가
// - AddUrgentTodoIntent: 긴급 우선순위 할일 추가
// - AddTodoError: 생성 단계 검증 에러
import AppIntents
import Foundation

// MARK: - 할일 추가 인텐트
/// Siri 또는 단축어를 통해 새 할일을 추가하는 인텐트
/// 예: "시리야, 할일에 장보기 추가해줘"
///
/// ## 사용 예시
/// - "시리야, 할일에 장보기 추가해줘"
/// - "시리야, 긴급한 보고서 작성 할일 만들어줘"
/// - "시리야, 내일까지 운동하기 추가해"
struct AddTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목 (단축어 앱에 표시)
    nonisolated static let title: LocalizedStringResource = "할일 추가"
    
    /// 인텐트 설명
    nonisolated static let description = IntentDescription(
        "새로운 할일을 목록에 추가합니다. 제목, 우선순위, 마감일을 지정할 수 있습니다.",
        categoryName: "생성",
        searchKeywords: ["할일", "추가", "만들기", "생성", "todo", "add", "create"]
    )
    
    /// Siri 대화 중 바로 실행 허용 (앱을 열지 않음)
    nonisolated static let openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 추가할 할일 제목 (필수)
    @Parameter(
        title: "할일 제목",
        description: "추가할 할일의 내용을 입력하세요",
        inputOptions: String.IntentInputOptions(
            keyboardType: .default,
            capitalizationType: .sentences,
            multiline: false,
            autocorrect: true,
            smartQuotes: true,
            smartDashes: true
        )
    )
    var title: String
    
    /// 상세 메모 (선택)
    @Parameter(
        title: "메모",
        description: "할일에 대한 상세 내용이나 메모",
        default: nil,
        inputOptions: String.IntentInputOptions(
            multiline: true
        )
    )
    var notes: String?
    
    /// 우선순위 (선택, 기본값: 보통)
    @Parameter(
        title: "우선순위",
        description: "할일의 중요도를 선택하세요",
        default: .normal
    )
    var priority: Priority
    
    /// 마감일 프리셋 (선택)
    @Parameter(
        title: "마감일",
        description: "마감일을 선택하세요",
        default: .none
    )
    var dueDatePreset: DueDatePreset
    
    /// 연결할 태그 (선택)
    @Parameter(
        title: "태그",
        description: "할일에 연결할 태그를 선택하세요"
    )
    var tags: [Tag]?
    
    // MARK: - 실행
    
    /// 인텐트 실행
    /// - Returns: 추가된 할일 정보와 결과 메시지
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        // 빈 제목 검증
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            throw AddTodoError.emptyTitle
        }
        
        // 제목 길이 검증 (최대 200자)
        guard trimmedTitle.count <= 200 else {
            throw AddTodoError.titleTooLong
        }
        
        // 태그 ID 추출
        let tagIds = tags?.map { $0.id } ?? []
        
        // 마감일 계산
        let dueDate = dueDatePreset.date
        
        // 할일 추가
        let newTodo = TodoStore.shared.add(
            title: trimmedTitle,
            notes: notes?.trimmingCharacters(in: .whitespaces),
            priority: priority,
            dueDate: dueDate,
            tagIds: tagIds
        )
        
        // 결과 메시지 생성
        let dialog = buildResultDialog(for: newTodo)
        
        return .result(
            value: newTodo,
            dialog: IntentDialog(stringLiteral: dialog)
        )
    }
    
    // MARK: - 결과 메시지 생성
    
    /// 결과 대화 메시지 생성
    private func buildResultDialog(for todo: TodoItem) -> String {
        var message = "\"\(todo.title)\" 할일을 추가했습니다"
        
        // 우선순위가 보통이 아니면 표시
        if priority != .normal {
            message += " (\(priority.displayName) 우선순위)"
        }
        
        // 마감일이 있으면 표시
        if let dueDate = todo.dueDateInfo {
            message += ". 마감일: \(dueDate.shortDateString)"
        }
        
        return message
    }
    
    // MARK: - 파라미터 요약 (단축어 앱 표시용)
    
    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$title)' 할일 추가")
    }
}

// MARK: - 빠른 할일 추가 인텐트
/// 최소한의 정보로 빠르게 할일을 추가하는 간편 인텐트
/// 예: "시리야, 빨리 장보기 추가해"
struct QuickAddTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    nonisolated static let title: LocalizedStringResource = "빠른 할일 추가"
    
    nonisolated static let description = IntentDescription(
        "제목만으로 빠르게 할일을 추가합니다.",
        categoryName: "생성",
        searchKeywords: ["빠른", "간단", "quick", "fast"]
    )
    
    nonisolated static let openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "할일",
        description: "추가할 할일 내용",
        requestValueDialog: IntentDialog("어떤 할일을 추가할까요?")
    )
    var title: String
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw AddTodoError.emptyTitle
        }
        
        let newTodo = TodoStore.shared.add(title: trimmed)
        
        return .result(
            value: newTodo,
            dialog: "'\(trimmed)' 추가 완료! ✅"
        )
    }
    
    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$title)' 빠르게 추가")
    }
}

// MARK: - 오늘 할일 추가 인텐트
/// 오늘 마감으로 할일을 추가하는 인텐트
struct AddTodayTodoIntent: AppIntent {
    
    nonisolated static let title: LocalizedStringResource = "오늘 할일 추가"
    
    nonisolated static let description = IntentDescription(
        "오늘 마감인 할일을 추가합니다.",
        categoryName: "생성"
    )
    
    nonisolated static let openAppWhenRun: Bool = false
    
    @Parameter(title: "할일 제목")
    var title: String
    
    @Parameter(title: "우선순위", default: .high)
    var priority: Priority
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw AddTodoError.emptyTitle
        }
        
        let newTodo = TodoStore.shared.add(
            title: trimmed,
            priority: priority,
            dueDate: DueDate.today.date
        )
        
        return .result(
            value: newTodo,
            dialog: "📅 오늘 할일 '\(trimmed)' 추가 완료!"
        )
    }
    
    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("오늘 할일 '\(\.$title)' 추가 (\(\.$priority))")
    }
}

// MARK: - 긴급 할일 추가 인텐트
/// 긴급 우선순위로 할일을 추가하는 인텐트
struct AddUrgentTodoIntent: AppIntent {
    
    nonisolated static let title: LocalizedStringResource = "긴급 할일 추가"
    
    nonisolated static let description = IntentDescription(
        "긴급 우선순위로 할일을 추가합니다.",
        categoryName: "생성"
    )
    
    nonisolated static let openAppWhenRun: Bool = false
    
    @Parameter(title: "할일 제목")
    var title: String
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<TodoItem> {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw AddTodoError.emptyTitle
        }
        
        let newTodo = TodoStore.shared.add(
            title: trimmed,
            priority: .urgent,
            dueDate: DueDate.today.date
        )
        
        return .result(
            value: newTodo,
            dialog: "🔴 긴급 할일 '\(trimmed)' 추가 완료!"
        )
    }
    
    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("긴급 할일 '\(\.$title)' 추가")
    }
}

// MARK: - 에러 정의
/// 할일 추가 관련 에러
enum AddTodoError: Error, CustomLocalizedStringResourceConvertible {
    case emptyTitle                 // 빈 제목
    case titleTooLong               // 제목이 너무 김
    case duplicateTitle             // 중복된 제목
    
    nonisolated var localizedStringResource: LocalizedStringResource {
        switch self {
        case .emptyTitle:
            return "할일 제목을 입력해주세요"
        case .titleTooLong:
            return "할일 제목은 200자 이하로 입력해주세요"
        case .duplicateTitle:
            return "이미 같은 제목의 할일이 있습니다"
        }
    }
}
