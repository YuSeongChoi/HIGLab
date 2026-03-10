// 이 파일은 "할일 삭제 및 정리" 관련 App Intent를 모아둔 파일이다.
// 구성:
// - DeleteTodoIntent: 단일 할일 삭제
// - DeleteMultipleTodosIntent: 여러 할일 삭제
// - DeleteCompletedTodosIntent / DeleteOldTodosIntent / DeleteAllTodosIntent: 정리용 삭제
// - OldTodoPeriod, DeleteTodoError: 삭제 범위와 확인 에러 정의
import AppIntents

// MARK: - 할일 삭제 인텐트
/// Siri 또는 단축어를 통해 할일을 삭제하는 인텐트
/// 예: "시리야, 장보기 할일 삭제해"
///
/// ## 사용 예시
/// - "시리야, 장보기 할일 삭제해"
/// - "시리야, 할일 지워줘"
struct DeleteTodoIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    nonisolated static let title: LocalizedStringResource = "할일 삭제"
    
    /// 인텐트 설명
    nonisolated static let description = IntentDescription(
        "선택한 할일을 삭제합니다. 삭제된 할일은 복구할 수 없습니다.",
        categoryName: "관리",
        searchKeywords: ["삭제", "지우기", "제거", "delete", "remove"]
    )
    
    /// 앱 실행 없이 처리
    nonisolated static let openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    /// 삭제할 할일
    @Parameter(
        title: "할일",
        description: "삭제할 할일을 선택하세요",
        requestValueDialog: IntentDialog("어떤 할일을 삭제할까요?")
    )
    var todo: TodoItem
    
    /// 확인 (실수 방지)
    @Parameter(
        title: "확인",
        description: "삭제를 확인합니다",
        default: true
    )
    var confirmed: Bool
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // 확인되지 않은 경우
        guard confirmed else {
            return .result(
                dialog: "삭제가 취소되었습니다."
            )
        }
        
        // 삭제 전 제목 저장
        let title = todo.title
        
        // 할일 삭제
        let success = TodoStore.shared.delete(id: todo.id)
        
        if success {
            return .result(
                dialog: "🗑️ '\(title)' 할일을 삭제했습니다."
            )
        } else {
            return .result(
                dialog: "⚠️ '\(title)' 할일을 찾을 수 없습니다."
            )
        }
    }
    
    // MARK: - 파라미터 요약
    
    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 삭제")
    }
}

// MARK: - 여러 할일 삭제 인텐트
/// 여러 할일을 한 번에 삭제하는 인텐트
struct DeleteMultipleTodosIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    nonisolated static let title: LocalizedStringResource = "여러 할일 삭제"
    
    nonisolated static let description = IntentDescription(
        "선택한 여러 할일을 한 번에 삭제합니다.",
        categoryName: "관리"
    )
    
    nonisolated static let openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "할일 목록",
        description: "삭제할 할일들을 선택하세요"
    )
    var todos: [TodoItem]
    
    @Parameter(
        title: "확인",
        default: false
    )
    var confirmed: Bool
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard !todos.isEmpty else {
            return .result(dialog: "삭제할 할일이 선택되지 않았습니다.")
        }
        
        guard confirmed else {
            throw DeleteTodoError.needsConfirmation(count: todos.count)
        }
        
        let ids = todos.map { $0.id }
        let deletedCount = TodoStore.shared.delete(ids: ids)
        
        return .result(
            dialog: "🗑️ \(deletedCount)개 할일을 삭제했습니다."
        )
    }
    
    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("\(\.$todos) 삭제")
    }
}

// MARK: - 완료된 할일 삭제 인텐트
/// 완료된 모든 할일을 삭제하는 인텐트
struct DeleteCompletedTodosIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    nonisolated static let title: LocalizedStringResource = "완료된 할일 삭제"
    
    nonisolated static let description = IntentDescription(
        "완료된 모든 할일을 삭제합니다. 정리에 유용합니다.",
        categoryName: "관리"
    )
    
    nonisolated static let openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "확인",
        description: "완료된 모든 할일 삭제를 확인합니다",
        default: false
    )
    var confirmed: Bool
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = TodoStore.shared
        let completedCount = store.completedTodos.count
        
        guard completedCount > 0 else {
            return .result(dialog: "삭제할 완료된 할일이 없습니다.")
        }
        
        guard confirmed else {
            throw DeleteTodoError.needsConfirmation(count: completedCount)
        }
        
        let deletedCount = store.deleteAllCompleted()
        
        return .result(
            dialog: "🧹 완료된 \(deletedCount)개 할일을 정리했습니다!"
        )
    }
    
    nonisolated static var parameterSummary: some ParameterSummary {
        When(\.$confirmed, .equalTo, true) {
            Summary("완료된 할일 모두 삭제 (확인됨)")
        } otherwise: {
            Summary("완료된 할일 모두 삭제")
        }
    }
}

// MARK: - 오래된 할일 삭제 인텐트
/// 특정 기간 이상 지난 완료된 할일을 삭제하는 인텐트
struct DeleteOldTodosIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    nonisolated static let title: LocalizedStringResource = "오래된 할일 삭제"
    
    nonisolated static let description = IntentDescription(
        "특정 기간 이상 지난 완료된 할일을 삭제합니다.",
        categoryName: "관리"
    )
    
    nonisolated static let openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "기준 기간",
        description: "이 기간 이상 지난 할일을 삭제합니다",
        default: .oneWeek
    )
    var period: OldTodoPeriod
    
    @Parameter(
        title: "확인",
        default: false
    )
    var confirmed: Bool
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = TodoStore.shared
        let calendar = Calendar.current
        let now = Date()
        
        // 기준 날짜 계산
        let cutoffDate: Date
        switch period {
        case .oneWeek:
            cutoffDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
        case .twoWeeks:
            cutoffDate = calendar.date(byAdding: .weekOfYear, value: -2, to: now)!
        case .oneMonth:
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths:
            cutoffDate = calendar.date(byAdding: .month, value: -3, to: now)!
        }
        
        // 삭제 대상 찾기
        let oldTodos = store.completedTodos.filter { todo in
            guard let completedAt = todo.completedAt else { return false }
            return completedAt < cutoffDate
        }
        
        guard !oldTodos.isEmpty else {
            return .result(
                dialog: "\(period.displayName) 이상 지난 완료된 할일이 없습니다."
            )
        }
        
        guard confirmed else {
            throw DeleteTodoError.needsConfirmation(count: oldTodos.count)
        }
        
        let ids = oldTodos.map { $0.id }
        let deletedCount = store.delete(ids: ids)
        
        return .result(
            dialog: "🧹 \(period.displayName) 이상 지난 \(deletedCount)개 할일을 정리했습니다!"
        )
    }
    
    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("\(\.$period) 이상 지난 할일 삭제")
    }
}

// MARK: - 오래된 할일 기간 열거형
enum OldTodoPeriod: String, AppEnum {
    case oneWeek = "oneWeek"
    case twoWeeks = "twoWeeks"
    case oneMonth = "oneMonth"
    case threeMonths = "threeMonths"
    
    var displayName: String {
        switch self {
        case .oneWeek: return "1주일"
        case .twoWeeks: return "2주일"
        case .oneMonth: return "1개월"
        case .threeMonths: return "3개월"
        }
    }
    
    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "기간")
    }
    
    nonisolated static var caseDisplayRepresentations: [OldTodoPeriod: DisplayRepresentation] {
        [
            .oneWeek: DisplayRepresentation(title: "1주일"),
            .twoWeeks: DisplayRepresentation(title: "2주일"),
            .oneMonth: DisplayRepresentation(title: "1개월"),
            .threeMonths: DisplayRepresentation(title: "3개월")
        ]
    }
}

// MARK: - 삭제 에러
enum DeleteTodoError: Error, CustomLocalizedStringResourceConvertible {
    case notFound
    case needsConfirmation(count: Int)
    
    nonisolated var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notFound:
            return "해당 할일을 찾을 수 없습니다"
        case .needsConfirmation(let count):
            return "\(count)개 할일을 삭제하시겠습니까? confirmed를 true로 설정하세요."
        }
    }
}

// MARK: - 모든 할일 삭제 인텐트 (주의 필요)
/// 모든 할일을 삭제하는 인텐트 (복구 불가)
struct DeleteAllTodosIntent: AppIntent {
    
    // MARK: - 메타데이터
    
    nonisolated static let title: LocalizedStringResource = "모든 할일 삭제"
    
    nonisolated static let description = IntentDescription(
        "⚠️ 모든 할일을 삭제합니다. 이 작업은 복구할 수 없습니다!",
        categoryName: "관리"
    )
    
    nonisolated static let openAppWhenRun: Bool = false
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "확인",
        description: "정말 모든 할일을 삭제하시겠습니까? 복구할 수 없습니다!",
        default: false
    )
    var confirmed: Bool
    
    @Parameter(
        title: "이중 확인",
        description: "'삭제합니다'라고 입력하세요",
        default: nil
    )
    var confirmText: String?
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = TodoStore.shared
        let totalCount = store.todos.count
        
        guard totalCount > 0 else {
            return .result(dialog: "삭제할 할일이 없습니다.")
        }
        
        guard confirmed else {
            throw DeleteTodoError.needsConfirmation(count: totalCount)
        }
        
        guard confirmText == "삭제합니다" else {
            return .result(
                dialog: "⚠️ 안전을 위해 confirmText에 '삭제합니다'를 입력해주세요."
            )
        }
        
        store.reset()
        
        return .result(
            dialog: "🗑️ \(totalCount)개의 모든 할일을 삭제했습니다."
        )
    }
    
    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("⚠️ 모든 할일 삭제")
    }
}
