import SwiftUI

// 이 파일은 SiriTodo 샘플의 "목록 화면 개념"을 현재 프로젝트에서 간단히 보여주기 위한 참고용 뷰다.
// 구성:
// - SiriTodoSampleContentView: 샘플 목록 화면
// - SiriTodoSampleRowView: 할일 1개 표시
// 참고:
// - 기존 샘플의 실제 앱용 ContentView는 현재 프로젝트의 동일 이름 타입과 충돌할 수 있으므로 제거했다.
// - 이 파일은 App Intents 학습에서 다루는 Todo 모델을 시각적으로 확인하는 최소 UI만 남긴 상태다.

struct SiriTodoSampleContentView: View {
    @State private var sampleTodos: [TodoItem] = [
        TodoItem(title: "Siri로 할일 추가해보기", priority: .high, dueDate: DueDate.today.date),
        TodoItem(title: "Shortcuts에서 실행 확인", priority: .normal),
        TodoItem(title: "우선순위 변경 Intent 테스트", priority: .urgent, dueDate: DueDate.tomorrow.date)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sample Todo List")
                .font(.headline)

            ForEach(sampleTodos) { todo in
                SiriTodoSampleRowView(todo: todo)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SiriTodoSampleRowView: View {
    let todo: TodoItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                Text(todo.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(todo.priority.emoji)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
