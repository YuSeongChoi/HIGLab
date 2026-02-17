import SwiftUI

// MARK: - 앱 진입점
/// SiriTodo 앱의 메인 진입점
/// AppIntents를 통해 Siri 및 단축어와 연동됩니다.
@main
struct SiriTodoApp: App {
    
    // 할일 저장소를 환경 객체로 주입
    @StateObject private var store = TodoStore.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
