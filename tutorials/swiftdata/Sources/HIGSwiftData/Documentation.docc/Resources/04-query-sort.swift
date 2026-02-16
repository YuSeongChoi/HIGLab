import SwiftUI
import SwiftData

// @Query with SortDescriptor
// 정렬된 결과 가져오기

struct TaskListView: View {
    // 생성일 기준 내림차순 (최신 먼저)
    @Query(sort: \TaskItem.createdAt, order: .reverse)
    private var tasks: [TaskItem]
    
    var body: some View {
        List(tasks) { task in
            TaskRowView(task: task)
        }
    }
}

// ─────────────────────────────────────────

// 다양한 정렬 예시

struct SortExamplesView: View {
    // 1. 제목 오름차순 (A → Z)
    @Query(sort: \TaskItem.title)
    private var tasksByTitle: [TaskItem]
    
    // 2. 우선순위 내림차순 (긴급 먼저)
    @Query(sort: \TaskItem.priority.rawValue, order: .reverse)
    private var tasksByPriority: [TaskItem]
    
    // 3. 마감일 오름차순 (임박한 것 먼저)
    @Query(sort: \TaskItem.dueDate)
    private var tasksByDueDate: [TaskItem]
    
    // 4. 완료 상태 (미완료 먼저)
    @Query(sort: \TaskItem.isCompleted)
    private var tasksByStatus: [TaskItem]
    
    var body: some View {
        Text("정렬 예시")
    }
}

// ─────────────────────────────────────────

// SortDescriptor 직접 사용

struct DescriptorExampleView: View {
    @Query(sort: [
        SortDescriptor(\TaskItem.createdAt, order: .reverse)
    ])
    private var tasks: [TaskItem]
    
    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
    }
}

// 💡 정렬 팁:
// - KeyPath로 간단하게 지정
// - SortDescriptor로 복잡한 정렬
// - Optional 프로퍼티도 정렬 가능 (nil은 마지막)
// - 문자열은 기본적으로 대소문자 구분
