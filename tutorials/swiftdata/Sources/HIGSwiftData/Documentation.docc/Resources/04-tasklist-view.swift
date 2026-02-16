import SwiftUI
import SwiftData

// TaskMaster 메인 리스트 뷰

struct TaskListView: View {
    // 우선순위 높은 순 → 생성일 최신 순
    @Query(
        sort: [
            SortDescriptor(\TaskItem.priority.rawValue, order: .reverse),
            SortDescriptor(\TaskItem.createdAt, order: .reverse)
        ],
        animation: .default
    )
    private var tasks: [TaskItem]
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            .navigationTitle("TaskMaster")
            .toolbar {
                toolbarContent
            }
        }
    }
    
    // MARK: - 빈 상태
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("할 일이 없습니다", systemImage: "checkmark.circle")
        } description: {
            Text("+ 버튼을 눌러 새로운 할 일을 추가하세요")
        } actions: {
            Button("샘플 데이터 추가") {
                addSampleData()
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - 리스트
    
    private var taskListView: some View {
        List {
            // 미완료 섹션
            Section {
                ForEach(tasks.filter { !$0.isCompleted }) { task in
                    TaskRowView(task: task)
                }
                .onDelete(perform: deleteTasks)
            } header: {
                Text("할 일 (\(tasks.filter { !$0.isCompleted }.count))")
            }
            
            // 완료 섹션
            let completedTasks = tasks.filter { $0.isCompleted }
            if !completedTasks.isEmpty {
                Section {
                    ForEach(completedTasks) { task in
                        TaskRowView(task: task)
                    }
                    .onDelete(perform: deleteCompletedTasks)
                } header: {
                    Text("완료됨 (\(completedTasks.count))")
                }
            }
        }
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                addNewTask()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
        }
    }
    
    // MARK: - Actions
    
    private func addNewTask() {
        let task = TaskItem(title: "새 할 일")
        context.insert(task)
    }
    
    private func addSampleData() {
        for sample in TaskItem.samples {
            context.insert(sample)
        }
    }
    
    private func deleteTasks(at offsets: IndexSet) {
        let pendingTasks = tasks.filter { !$0.isCompleted }
        for index in offsets {
            context.delete(pendingTasks[index])
        }
    }
    
    private func deleteCompletedTasks(at offsets: IndexSet) {
        let completedTasks = tasks.filter { $0.isCompleted }
        for index in offsets {
            context.delete(completedTasks[index])
        }
    }
}

// ─────────────────────────────────────────

struct TaskRowView: View {
    @Bindable var task: TaskItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 완료 토글 버튼
            Button {
                withAnimation {
                    task.toggleCompletion()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // 내용
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 우선순위
            Text(task.priority.emoji)
                .font(.title3)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
