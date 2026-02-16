import SwiftData
import SwiftUI

// ModelContainer: 데이터 저장소
// SQLite, 메모리, CloudKit 등 다양한 백엔드 지원

// 가장 간단한 설정 (앱 진입점)
@main
struct TaskMasterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // 이 한 줄로 SwiftData 설정 완료!
        .modelContainer(for: TaskItem.self)
    }
}

// ─────────────────────────────────────────

// 여러 모델을 함께 사용할 때
@main
struct MultiModelApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [TaskItem.self, Category.self])
    }
}

// ─────────────────────────────────────────

// 커스텀 설정이 필요할 때
@main
struct CustomApp: App {
    let container: ModelContainer
    
    init() {
        let schema = Schema([TaskItem.self, Category.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,    // true면 메모리만 사용
            allowsSave: true,                // false면 읽기 전용
            groupContainer: .automatic       // App Group 공유
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Container 초기화 실패: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
