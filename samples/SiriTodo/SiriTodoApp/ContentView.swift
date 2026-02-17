import SwiftUI

// MARK: - 메인 할일 목록 뷰
/// 할일 목록을 표시하고 관리하는 메인 화면
struct ContentView: View {
    
    @EnvironmentObject var store: TodoStore
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: 미완료 섹션
                Section {
                    ForEach(store.incompleteTodos) { todo in
                        TodoRowView(todo: todo)
                    }
                    .onDelete(perform: deleteIncomplete)
                } header: {
                    if !store.incompleteTodos.isEmpty {
                        Text("진행 중")
                    }
                }
                
                // MARK: 완료 섹션
                Section {
                    ForEach(store.completedTodos) { todo in
                        TodoRowView(todo: todo)
                    }
                    .onDelete(perform: deleteCompleted)
                } header: {
                    if !store.completedTodos.isEmpty {
                        Text("완료됨")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("할일 목록")
            .toolbar {
                // 추가 버튼
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTodoView()
            }
            .overlay {
                // 빈 상태 표시
                if store.todos.isEmpty {
                    ContentUnavailableView {
                        Label("할일이 없습니다", systemImage: "checkmark.circle")
                    } description: {
                        Text("새 할일을 추가하거나\nSiri에게 \"할일 추가해줘\"라고 말해보세요")
                    } actions: {
                        Button("할일 추가") {
                            showingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    
    // MARK: - 삭제 핸들러
    
    /// 미완료 항목 삭제
    private func deleteIncomplete(at offsets: IndexSet) {
        for index in offsets {
            let todo = store.incompleteTodos[index]
            store.delete(todo)
        }
    }
    
    /// 완료 항목 삭제
    private func deleteCompleted(at offsets: IndexSet) {
        for index in offsets {
            let todo = store.completedTodos[index]
            store.delete(todo)
        }
    }
}

// MARK: - 할일 행 뷰
/// 개별 할일 항목을 표시하는 행
struct TodoRowView: View {
    
    @EnvironmentObject var store: TodoStore
    let todo: TodoItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 완료 체크 버튼
            Button {
                withAnimation {
                    if !todo.isCompleted {
                        store.complete(todo)
                    }
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(todo.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // 할일 제목
            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                
                // 완료 시간 표시
                if let completedAt = todo.completedAt {
                    Text(completedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 프리뷰
#Preview {
    ContentView()
        .environmentObject(TodoStore.shared)
}
