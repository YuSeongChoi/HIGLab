import SwiftUI
import SwiftData

// 동적 필터링 패턴
// @Query의 filter는 고정값이므로, 부모-자식 뷰 패턴 사용

// MARK: - 부모 뷰 (필터 조건 관리)

struct TaskContainerView: View {
    @State private var showCompleted = false
    @State private var selectedPriority: Priority? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                // 필터 컨트롤
                filterControls
                
                // 필터 조건에 따라 다른 뷰 표시
                if let priority = selectedPriority {
                    FilteredByPriorityView(priority: priority, showCompleted: showCompleted)
                } else {
                    FilteredByCompletionView(showCompleted: showCompleted)
                }
            }
            .navigationTitle("할 일")
        }
    }
    
    private var filterControls: some View {
        VStack {
            Toggle("완료된 항목 표시", isOn: $showCompleted)
            
            Picker("우선순위", selection: $selectedPriority) {
                Text("전체").tag(nil as Priority?)
                ForEach(Priority.allCases) { priority in
                    Text(priority.title).tag(priority as Priority?)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }
}

// ─────────────────────────────────────────

// MARK: - 자식 뷰 (고정 필터)

struct FilteredByCompletionView: View {
    let showCompleted: Bool
    
    // 조건에 따라 다른 @Query 사용
    @Query private var tasks: [TaskItem]
    
    init(showCompleted: Bool) {
        self.showCompleted = showCompleted
        
        // 동적으로 predicate 생성
        let predicate = #Predicate<TaskItem> { task in
            showCompleted ? task.isCompleted : !task.isCompleted
        }
        
        _tasks = Query(filter: predicate, sort: \TaskItem.createdAt, order: .reverse)
    }
    
    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
    }
}

// ─────────────────────────────────────────

struct FilteredByPriorityView: View {
    let priority: Priority
    let showCompleted: Bool
    
    @Query private var tasks: [TaskItem]
    
    init(priority: Priority, showCompleted: Bool) {
        self.priority = priority
        self.showCompleted = showCompleted
        
        let predicate = #Predicate<TaskItem> { task in
            task.priority == priority && (showCompleted || !task.isCompleted)
        }
        
        _tasks = Query(filter: predicate, sort: \TaskItem.createdAt, order: .reverse)
    }
    
    var body: some View {
        List(tasks) { task in
            HStack {
                Text(task.priority.emoji)
                Text(task.title)
            }
        }
    }
}

// 💡 핵심 패턴:
// 1. 부모: @State로 필터 조건 관리
// 2. 자식: init에서 조건 받아 @Query 초기화
// 3. 조건 변경 → 자식 뷰 재생성 → 새 Query 실행
