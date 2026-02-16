import SwiftUI
import SwiftData

// @Query: 가장 간단한 사용법
// 해당 모델의 모든 데이터를 가져옴

struct TaskListView: View {
    // ✨ 이 한 줄로 모든 TaskItem을 가져옴!
    @Query private var tasks: [TaskItem]
    
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                TaskRowView(task: task)
            }
            .navigationTitle("할 일 목록")
            .overlay {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "할 일이 없습니다",
                        systemImage: "checkmark.circle",
                        description: Text("새로운 할 일을 추가해보세요")
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────

struct TaskRowView: View {
    let task: TaskItem
    
    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .green : .gray)
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                
                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(task.priority.emoji)
        }
    }
}

// 💡 @Query 동작 원리:
// 1. 뷰가 나타날 때 자동으로 fetch 실행
// 2. ModelContext의 변경사항 자동 감지
// 3. 데이터 변경 시 뷰 자동 업데이트
// 4. 뷰가 사라지면 구독 해제
