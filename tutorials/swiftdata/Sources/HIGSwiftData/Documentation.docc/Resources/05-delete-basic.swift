import SwiftUI
import SwiftData

// Delete: 기본 삭제

struct DeleteExampleView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TaskItem.createdAt, order: .reverse, animation: .default)
    private var tasks: [TaskItem]
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskRowView(task: task)
            }
            // onDelete로 스와이프 삭제 지원
            .onDelete(perform: deleteTasks)
        }
    }
    
    // IndexSet으로 삭제
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            context.delete(tasks[index])
        }
    }
}

// ─────────────────────────────────────────

// 개별 삭제 버튼

struct TaskRowWithDelete: View {
    @Environment(\.modelContext) private var context
    let task: TaskItem
    
    var body: some View {
        HStack {
            Text(task.title)
            
            Spacer()
            
            // 삭제 버튼
            Button(role: .destructive) {
                withAnimation {
                    context.delete(task)
                }
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}

// ─────────────────────────────────────────

// 스와이프 액션으로 삭제

struct SwipeDeleteView: View {
    @Query(animation: .default) private var tasks: [TaskItem]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List(tasks) { task in
            Text(task.title)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        context.delete(task)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
        }
    }
}

// ─────────────────────────────────────────

// 확인 후 삭제 (Alert)

struct ConfirmDeleteView: View {
    @Environment(\.modelContext) private var context
    let task: TaskItem
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            Label("삭제", systemImage: "trash")
        }
        .alert("할 일 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                withAnimation {
                    context.delete(task)
                }
            }
        } message: {
            Text("'\(task.title)'을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.")
        }
    }
}

// 💡 삭제 팁:
// 1. withAnimation으로 부드러운 UI 전환
// 2. 중요한 데이터는 확인 대화상자 표시
// 3. 관계 객체는 @Relationship의 deleteRule 확인
// 4. 대량 삭제는 백그라운드 컨텍스트 사용
