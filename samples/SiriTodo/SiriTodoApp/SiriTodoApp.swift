import SwiftUI
import AppIntents

// MARK: - 앱 진입점
/// SiriTodo 앱의 메인 진입점
/// AppIntents를 통해 Siri 및 단축어와 연동됩니다.
///
/// ## 주요 기능
/// - Siri 음성 명령으로 할일 관리
/// - 단축어 앱 연동
/// - 위젯 지원
/// - 딥링크 처리
@main
struct SiriTodoApp: App {
    
    // MARK: - 상태 객체
    
    /// 할일 저장소
    @StateObject private var todoStore = TodoStore.shared
    
    /// 태그 저장소
    @StateObject private var tagStore = TagStore.shared
    
    /// 네비게이션 관리자
    @StateObject private var navigationManager = NavigationManager.shared
    
    // MARK: - 앱 델리게이트
    
    /// iOS 앱 델리게이트 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - 씬
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoStore)
                .environmentObject(tagStore)
                .environmentObject(navigationManager)
                .onOpenURL(perform: handleURL)
        }
    }
    
    // MARK: - URL 처리
    
    /// 딥링크 URL 처리
    /// - Parameter url: 열린 URL
    private func handleURL(_ url: URL) {
        navigationManager.handle(url: url)
    }
}

// MARK: - 앱 델리게이트
/// iOS 앱 생명주기 이벤트 처리
final class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// 앱 실행 완료
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Siri 단축어 업데이트
        updateAppShortcutParameters()
        
        return true
    }
    
    /// 앱이 포그라운드로 진입
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 단축어 파라미터 업데이트
        updateAppShortcutParameters()
    }
    
    /// 백그라운드에서 URL 열기
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        NavigationManager.shared.handle(url: url)
        return true
    }
    
    /// 단축어 파라미터 업데이트
    private func updateAppShortcutParameters() {
        Task {
            // 단축어 앱에 최신 데이터 반영
            try? await AppShortcuts.updateAppShortcutParameters()
        }
    }
}

// MARK: - 앱 정보
/// 앱 관련 상수 및 설정
enum AppInfo {
    /// 앱 이름
    static let appName = "SiriTodo"
    
    /// 앱 번들 ID
    static let bundleId = "com.example.SiriTodo"
    
    /// 앱 그룹 ID (위젯/인텐트 공유용)
    static let appGroupId = "group.com.example.SiriTodo"
    
    /// 앱 버전
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// 빌드 번호
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// 전체 버전 문자열
    static var fullVersion: String {
        "\(version) (\(build))"
    }
}

// MARK: - 앱 테마
/// 앱 전체 테마 설정
enum AppTheme {
    /// 기본 색상
    static let primaryColor = Color.blue
    static let secondaryColor = Color.gray
    static let accentColor = Color.orange
    
    /// 우선순위 색상
    static func color(for priority: Priority) -> Color {
        switch priority {
        case .low: return .gray
        case .normal: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    /// 상태 색상
    static let completedColor = Color.green
    static let incompleteColor = Color.gray
    static let overdueColor = Color.red
}

// MARK: - 환경 키
/// SwiftUI 환경에서 사용할 커스텀 키
private struct TodoStoreKey: EnvironmentKey {
    static let defaultValue = TodoStore.shared
}

private struct TagStoreKey: EnvironmentKey {
    static let defaultValue = TagStore.shared
}

private struct NavigationManagerKey: EnvironmentKey {
    static let defaultValue = NavigationManager.shared
}

extension EnvironmentValues {
    /// 할일 저장소
    var todoStore: TodoStore {
        get { self[TodoStoreKey.self] }
        set { self[TodoStoreKey.self] = newValue }
    }
    
    /// 태그 저장소
    var tagStore: TagStore {
        get { self[TagStoreKey.self] }
        set { self[TagStoreKey.self] = newValue }
    }
    
    /// 네비게이션 관리자
    var navigationManager: NavigationManager {
        get { self[NavigationManagerKey.self] }
        set { self[NavigationManagerKey.self] = newValue }
    }
}
