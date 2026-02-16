import SwiftUI
import SwiftData

// 새 할 일 추가 시트

struct AddTaskSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // 입력 상태
    @State private var title = ""
    @State private var note = ""
    @State private var priority: Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                // 제목 (필수)
                Section {
                    TextField("할 일", text: $title)
                    TextField("메모", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // 우선순위
                Section("우선순위") {
                    Picker("우선순위", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Label(p.title, systemImage: "flag.fill")
                                .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 마감일
                Section {
                    Toggle("마감일 설정", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(
                            "마감일",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle("새 할 일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        addTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addTask() {
        let task = TaskItem(
            title: title.trimmingCharacters(in: .whitespaces),
            note: note,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )
        context.insert(task)
        dismiss()
    }
}

// ─────────────────────────────────────────

// 메인 뷰에서 시트 호출

struct TaskListWithAddButton: View {
    @Query private var tasks: [TaskItem]
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                Text(task.title)
            }
            .navigationTitle("할 일")
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTaskSheet()
            }
        }
    }
}

#Preview {
    AddTaskSheet()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
