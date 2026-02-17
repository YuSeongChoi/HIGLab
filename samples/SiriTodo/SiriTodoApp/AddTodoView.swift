import SwiftUI

// MARK: - 할일 추가 뷰
/// 새 할일을 추가하는 시트 화면
struct AddTodoView: View {
    
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: 제목 입력
                Section {
                    TextField("할일 입력", text: $title)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit(addTodo)
                } header: {
                    Text("새 할일")
                } footer: {
                    Text("Siri에게 \"[제목] 할일에 추가해줘\"라고 말해도 됩니다")
                }
                
                // MARK: 빠른 추가 예시
                Section {
                    ForEach(quickAddExamples, id: \.self) { example in
                        Button {
                            title = example
                        } label: {
                            HStack {
                                Image(systemName: "lightbulb")
                                    .foregroundStyle(.yellow)
                                Text(example)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                } header: {
                    Text("예시")
                }
            }
            .navigationTitle("할일 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 취소 버튼
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                // 추가 버튼
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        addTodo()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                // 자동 포커스
                isFocused = true
            }
        }
    }
    
    // MARK: - 빠른 추가 예시
    private let quickAddExamples = [
        "장보기",
        "이메일 확인하기",
        "운동하기",
        "책 읽기"
    ]
    
    // MARK: - 할일 추가
    private func addTodo() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        store.add(title: trimmed)
        dismiss()
    }
}

// MARK: - 프리뷰
#Preview {
    AddTodoView()
        .environmentObject(TodoStore.shared)
}
