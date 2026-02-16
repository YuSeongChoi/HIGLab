import SwiftUI
import SwiftData

// 편집 시트 (취소 시 롤백 지원)

struct EditTaskSheet: View {
    @Bindable var task: TaskItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // 원본 값 백업 (취소 시 복원용)
    @State private var originalTitle: String = ""
    @State private var originalNote: String = ""
    @State private var originalPriority: Priority = .medium
    @State private var originalDueDate: Date? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("제목", text: $task.title)
                    
                    TextField("메모", text: $task.note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("설정") {
                    Picker("우선순위", selection: $task.priority) {
                        ForEach(Priority.allCases) { priority in
                            HStack {
                                Text(priority.emoji)
                                Text(priority.title)
                            }
                            .tag(priority)
                        }
                    }
                    
                    dueDatePicker
                }
                
                Section("상태") {
                    Toggle("완료", isOn: $task.isCompleted)
                }
            }
            .navigationTitle("편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        restoreOriginal()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                    .disabled(task.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                backupOriginal()
            }
        }
    }
    
    // MARK: - 마감일 Picker
    
    @ViewBuilder
    private var dueDatePicker: some View {
        Toggle("마감일", isOn: Binding(
            get: { task.dueDate != nil },
            set: { newValue in
                if newValue {
                    task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: .now)
                } else {
                    task.dueDate = nil
                }
            }
        ))
        
        if let dueDate = Binding($task.dueDate) {
            DatePicker(
                "날짜",
                selection: dueDate,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }
    
    // MARK: - 백업 & 복원
    
    private func backupOriginal() {
        originalTitle = task.title
        originalNote = task.note
        originalPriority = task.priority
        originalDueDate = task.dueDate
    }
    
    private func restoreOriginal() {
        task.title = originalTitle
        task.note = originalNote
        task.priority = originalPriority
        task.dueDate = originalDueDate
    }
}

// ─────────────────────────────────────────

// 💡 취소/롤백 패턴
// 방법 1: 원본 값 백업 후 복원 (위 예시)
// 방법 2: context.rollback() 사용
// 방법 3: 별도 컨텍스트에서 작업 후 병합

// context.rollback() 사용 시:
// - 해당 컨텍스트의 모든 미저장 변경사항이 취소됨
// - 다른 변경사항도 함께 롤백되므로 주의

#Preview {
    EditTaskSheet(task: .preview)
        .modelContainer(for: TaskItem.self, inMemory: true)
}
