import SwiftData
import SwiftUI

// ✅ SwiftData의 단순함

// @Model 매크로 하나로 끝!
// 별도의 스키마 파일 불필요
// 순수 Swift 클래스가 곧 데이터 모델

@Model
class TaskItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, isCompleted: Bool = false, createdAt: Date = .now) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// 타입 안전한 쿼리
struct TaskListView: View {
    // @Query가 자동으로 데이터를 가져오고 UI를 업데이트
    @Query(filter: #Predicate<TaskItem> { !$0.isCompleted },
           sort: \TaskItem.createdAt, order: .reverse)
    private var tasks: [TaskItem]
    
    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
    }
}

// 컴파일 타임에 오타 검출!
// \TaskItem.createAt ← 컴파일 에러!
