import SwiftUI
import SwiftData

struct ContentView: View {
    // SwiftUI Environment에서 ModelContext 가져오기
    // 부모에서 .modelContainer 설정 필요
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("할 일 목록")
                
                Button("새 할 일 추가") {
                    addNewTask()
                }
            }
            .navigationTitle("TaskMaster")
        }
    }
    
    // context를 사용한 데이터 조작
    func addNewTask() {
        let task = TaskItem(title: "새로운 할 일")
        context.insert(task)
        // autosave가 자동으로 저장 처리
    }
}

// ─────────────────────────────────────────

// Environment가 없으면 에러!
// ⚠️ Thread 1: Fatal error: No ModelContext in the environment

// 해결책:
// 1. 부모 뷰에서 .modelContainer 설정
// 2. Preview에서도 modelContainer 제공

// ─────────────────────────────────────────

// 하위 뷰에서도 동일하게 접근
struct TaskRowView: View {
    @Environment(\.modelContext) private var context
    let task: TaskItem
    
    var body: some View {
        HStack {
            Text(task.title)
            Spacer()
            Button {
                task.toggleCompletion()
                // 변경은 자동 추적됨
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
            }
        }
    }
}
