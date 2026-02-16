import SwiftUI
import SwiftData

// @Query with #Predicate
// 타입 안전한 필터링

struct TaskListView: View {
    // 미완료 항목만 가져오기
    @Query(filter: #Predicate<TaskItem> { task in
        task.isCompleted == false
    })
    private var pendingTasks: [TaskItem]
    
    var body: some View {
        List(pendingTasks) { task in
            Text(task.title)
        }
    }
}

// ─────────────────────────────────────────

// 다양한 필터 예시

struct FilterExamplesView: View {
    // 1. 완료된 항목만
    @Query(filter: #Predicate<TaskItem> { $0.isCompleted })
    private var completedTasks: [TaskItem]
    
    // 2. 긴급 우선순위
    @Query(filter: #Predicate<TaskItem> { $0.priority == .urgent })
    private var urgentTasks: [TaskItem]
    
    // 3. 제목에 특정 문자 포함
    @Query(filter: #Predicate<TaskItem> { task in
        task.title.localizedStandardContains("중요")
    })
    private var importantTasks: [TaskItem]
    
    // 4. 오늘 마감인 항목
    @Query(filter: #Predicate<TaskItem> { task in
        if let dueDate = task.dueDate {
            return Calendar.current.isDateInToday(dueDate)
        }
        return false
    })
    private var todayTasks: [TaskItem]
    
    // 5. 복합 조건 (미완료 AND 높은 우선순위)
    @Query(filter: #Predicate<TaskItem> { task in
        !task.isCompleted && task.priority.rawValue >= 2
    })
    private var highPriorityPending: [TaskItem]
    
    var body: some View {
        Text("필터 예시")
    }
}

// ─────────────────────────────────────────

// 필터 + 정렬 조합

struct CombinedQueryView: View {
    @Query(
        filter: #Predicate<TaskItem> { !$0.isCompleted },
        sort: \TaskItem.priority.rawValue,
        order: .reverse
    )
    private var tasks: [TaskItem]
    
    var body: some View {
        List(tasks) { task in
            HStack {
                Text(task.priority.emoji)
                Text(task.title)
            }
        }
    }
}

// 💡 #Predicate vs NSPredicate
// #Predicate: 타입 안전, 컴파일 타임 검증, Swift 네이티브
// NSPredicate: 문자열 기반, 런타임 에러 가능, 레거시
