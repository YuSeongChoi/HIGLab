import SwiftUI
import SwiftData

// 여러 모델을 사용하는 경우

// 먼저 Category 모델 정의 (Chapter 6에서 상세 설명)
@Model
class Category {
    var name: String
    var color: String
    var tasks: [TaskItem]
    
    init(name: String, color: String = "blue", tasks: [TaskItem] = []) {
        self.name = name
        self.color = color
        self.tasks = tasks
    }
}

// ─────────────────────────────────────────

@main
struct TaskMasterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // 배열로 여러 모델 등록
        .modelContainer(for: [
            TaskItem.self,
            Category.self
        ])
    }
}

// ─────────────────────────────────────────

// 💡 팁: 관계가 있는 모델은 자동으로 포함됨
// TaskItem이 Category를 참조하면, Category만 등록해도 
// TaskItem이 자동 포함됨

// 하지만 명시적으로 모두 나열하는 것을 권장:
// - 코드 가독성 향상
// - 의존성 명확화
// - 실수 방지
