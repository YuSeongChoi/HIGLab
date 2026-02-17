import AppIntents
import SwiftUI

// MARK: - 앱 열기 인텐트
/// Siri 또는 단축어를 통해 SiriTodo 앱을 여는 인텐트
/// OpenIntent 프로토콜을 준수하여 앱을 열 수 있음
///
/// ## 사용 예시
/// - "시리야, 할일 앱 열어줘"
/// - "시리야, SiriTodo 실행해"
struct OpenSiriTodoIntent: AppIntent, OpenIntent {
    
    // MARK: - 메타데이터
    
    /// 인텐트 제목
    static var title: LocalizedStringResource = "SiriTodo 열기"
    
    /// 인텐트 설명
    static var description = IntentDescription(
        "SiriTodo 앱을 엽니다.",
        categoryName: "앱",
        searchKeywords: ["열기", "실행", "open", "launch"]
    )
    
    /// 앱을 열어야 하므로 true
    static var openAppWhenRun: Bool = true
    
    // MARK: - 대상 (선택적)
    
    /// 열 때 표시할 할일 (선택)
    @Parameter(
        title: "할일",
        description: "특정 할일을 선택하면 해당 할일로 이동합니다",
        default: nil
    )
    var target: TodoItem?
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let targetTodo = target {
            // 특정 할일로 이동하는 로직
            // 실제 구현에서는 NavigationPath나 DeepLink 사용
            return .result(dialog: "\"\(targetTodo.title)\" 할일을 열고 있습니다...")
        }
        
        return .result(dialog: "SiriTodo 앱을 열었습니다.")
    }
    
    // MARK: - 파라미터 요약
    
    static var parameterSummary: some ParameterSummary {
        When(\.$target, .hasAnyValue) {
            Summary("SiriTodo에서 '\(\.$target)' 열기")
        } otherwise: {
            Summary("SiriTodo 열기")
        }
    }
}

// MARK: - 할일 상세 보기 인텐트
/// 특정 할일의 상세 정보를 앱에서 보여주는 인텐트
/// ForegroundContinuableIntent를 준수하여 필요시 앱으로 전환
struct ViewTodoDetailIntent: AppIntent, ForegroundContinuableIntent {
    
    // MARK: - 메타데이터
    
    static var title: LocalizedStringResource = "할일 상세 보기"
    
    static var description = IntentDescription(
        "선택한 할일의 상세 정보를 앱에서 확인합니다.",
        categoryName: "조회"
    )
    
    // MARK: - 파라미터
    
    @Parameter(
        title: "할일",
        description: "상세 정보를 볼 할일을 선택하세요"
    )
    var todo: TodoItem
    
    // MARK: - 실행
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // 상세 정보 생성
        let detail = todo.detailedSummary
        
        return .result(dialog: IntentDialog(stringLiteral: detail))
    }
    
    // MARK: - 포그라운드 전환 필요 시
    
    /// 앱을 열어 더 상세한 정보를 보여줄 필요가 있는지 판단
    var needsToContinueInForegroundError: Error? {
        // 메모가 있으면 앱에서 보는 것이 좋음
        if todo.notes != nil && !(todo.notes?.isEmpty ?? true) {
            return ContinueInAppError.needsAppForDetails
        }
        return nil
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 상세 보기")
    }
}

// MARK: - 앱에서 계속 필요 에러
enum ContinueInAppError: Error, CustomLocalizedStringResourceConvertible {
    case needsAppForDetails
    case needsAppForEditing
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .needsAppForDetails:
            return "자세한 내용은 앱에서 확인하세요"
        case .needsAppForEditing:
            return "편집하려면 앱을 열어야 합니다"
        }
    }
}

// MARK: - 할일 편집 인텐트
/// 할일을 앱에서 편집하도록 여는 인텐트
struct EditTodoIntent: AppIntent, ForegroundContinuableIntent {
    
    static var title: LocalizedStringResource = "할일 편집"
    
    static var description = IntentDescription(
        "선택한 할일을 앱에서 편집합니다.",
        categoryName: "관리"
    )
    
    static var openAppWhenRun: Bool = true
    
    @Parameter(
        title: "할일",
        description: "편집할 할일을 선택하세요"
    )
    var todo: TodoItem
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // 앱에서 편집 화면으로 이동
        // 실제 구현에서는 DeepLink 또는 NavigationPath 사용
        return .result(dialog: "\"\(todo.title)\" 편집 화면을 열고 있습니다...")
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$todo)' 편집")
    }
}

// MARK: - 새 할일 추가 화면 열기 인텐트
/// 새 할일 추가 화면을 여는 인텐트
struct OpenAddTodoIntent: AppIntent, OpenIntent {
    
    static var title: LocalizedStringResource = "새 할일 추가 화면"
    
    static var description = IntentDescription(
        "새 할일을 추가할 수 있는 화면을 엽니다.",
        categoryName: "앱"
    )
    
    static var openAppWhenRun: Bool = true
    
    /// 미리 채울 제목 (선택)
    @Parameter(
        title: "제목",
        description: "미리 채울 할일 제목",
        default: nil
    )
    var prefillTitle: String?
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let title = prefillTitle, !title.isEmpty {
            return .result(dialog: "'\(title)' 할일 추가 화면을 열었습니다.")
        }
        return .result(dialog: "새 할일 추가 화면을 열었습니다.")
    }
    
    static var parameterSummary: some ParameterSummary {
        When(\.$prefillTitle, .hasAnyValue) {
            Summary("'\(\.$prefillTitle)' 할일 추가 화면 열기")
        } otherwise: {
            Summary("새 할일 추가 화면 열기")
        }
    }
}

// MARK: - 설정 화면 열기 인텐트
struct OpenSettingsIntent: AppIntent, OpenIntent {
    
    static var title: LocalizedStringResource = "설정 열기"
    
    static var description = IntentDescription(
        "SiriTodo 설정 화면을 엽니다.",
        categoryName: "앱"
    )
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "설정 화면을 열고 있습니다...")
    }
}

// MARK: - 통계 화면 열기 인텐트
struct OpenStatisticsIntent: AppIntent, OpenIntent {
    
    static var title: LocalizedStringResource = "통계 화면 열기"
    
    static var description = IntentDescription(
        "할일 통계 화면을 엽니다.",
        categoryName: "앱"
    )
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let stats = TodoStore.shared.statistics
        return .result(
            dialog: "통계 화면을 열고 있습니다. (완료율: \(stats.completionRateString))"
        )
    }
}

// MARK: - 딥링크 처리
/// 앱 내 화면 이동을 위한 딥링크 열거형
enum SiriTodoDeepLink: String {
    case home = "siritodo://home"
    case addTodo = "siritodo://add"
    case settings = "siritodo://settings"
    case statistics = "siritodo://statistics"
    case todo = "siritodo://todo"
    
    /// URL 생성
    var url: URL {
        URL(string: rawValue)!
    }
    
    /// 할일 ID로 딥링크 생성
    static func todoDetail(id: UUID) -> URL {
        URL(string: "siritodo://todo/\(id.uuidString)")!
    }
    
    /// 딥링크 파싱
    static func parse(_ url: URL) -> (DeepLinkType, UUID?) {
        let path = url.pathComponents
        
        switch url.host {
        case "home":
            return (.home, nil)
        case "add":
            return (.addTodo, nil)
        case "settings":
            return (.settings, nil)
        case "statistics":
            return (.statistics, nil)
        case "todo":
            if path.count > 1, let uuid = UUID(uuidString: path[1]) {
                return (.todoDetail, uuid)
            }
            return (.todoList, nil)
        default:
            return (.home, nil)
        }
    }
}

/// 딥링크 타입
enum DeepLinkType {
    case home
    case addTodo
    case todoList
    case todoDetail
    case settings
    case statistics
}

// MARK: - 앱 네비게이션 관리자
/// 앱 전체 네비게이션 상태를 관리하는 ObservableObject
/// 인텐트에서 앱을 열 때 특정 화면으로 이동하는 데 사용
@MainActor
final class NavigationManager: ObservableObject {
    
    static let shared = NavigationManager()
    
    /// 현재 표시할 화면
    @Published var activeScreen: DeepLinkType = .home
    
    /// 선택된 할일 ID
    @Published var selectedTodoId: UUID?
    
    /// 할일 추가 시트 표시 여부
    @Published var showingAddTodo: Bool = false
    
    /// 미리 채울 제목
    @Published var prefillTitle: String = ""
    
    private init() {}
    
    /// 딥링크로 네비게이션
    func navigate(to deepLink: SiriTodoDeepLink, todoId: UUID? = nil) {
        switch deepLink {
        case .home:
            activeScreen = .home
        case .addTodo:
            showingAddTodo = true
        case .settings:
            activeScreen = .settings
        case .statistics:
            activeScreen = .statistics
        case .todo:
            if let id = todoId {
                activeScreen = .todoDetail
                selectedTodoId = id
            } else {
                activeScreen = .todoList
            }
        }
    }
    
    /// URL로 네비게이션
    func handle(url: URL) {
        let (type, todoId) = SiriTodoDeepLink.parse(url)
        activeScreen = type
        selectedTodoId = todoId
        
        if type == .addTodo {
            showingAddTodo = true
        }
    }
}
