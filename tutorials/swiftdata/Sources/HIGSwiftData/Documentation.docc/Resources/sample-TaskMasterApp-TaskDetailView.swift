import SwiftUI
import SwiftData

// MARK: - 할일 상세/편집 뷰

/// 할일의 상세 정보를 표시하고 편집하는 뷰
/// - 모든 속성 편집 가능
/// - 완료/삭제 액션
struct TaskDetailView: View {
    // MARK: - 환경
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Category.order)
    private var categories: [Category]
    
    // MARK: - 속성
    
    @Bindable var task: TaskItem
    
    // MARK: - 상태
    
    @State private var showingDeleteAlert = false
    
    // MARK: - 뷰 본문
    
    var body: some View {
        Form {
            // 상태 섹션
            Section {
                statusRow
            }
            
            // 기본 정보 섹션
            Section("기본 정보") {
                // 제목
                TextField("제목", text: $task.title)
                
                // 우선순위
                Picker("우선순위", selection: $task.taskPriority) {
                    ForEach(TaskPriority.allCases) { priority in
                        Label(priority.name, systemImage: priority.symbol)
                            .tag(priority)
                    }
                }
            }
            
            // 마감일 섹션
            Section("마감일") {
                dueDateSection
            }
            
            // 카테고리 섹션
            Section("카테고리") {
                categorySection
            }
            
            // 메모 섹션
            Section("메모") {
                TextField("메모", text: $task.notes, axis: .vertical)
                    .lineLimit(3...10)
            }
            
            // 정보 섹션
            Section("정보") {
                infoRow(title: "생성일", value: formattedDate(task.createdAt))
                
                if let completedAt = task.completedAt {
                    infoRow(title: "완료일", value: formattedDate(completedAt))
                }
            }
            
            // 삭제 섹션
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Label("할일 삭제", systemImage: "trash")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("할일 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    task.toggleCompletion()
                } label: {
                    Image(systemName: task.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle.fill")
                }
            }
        }
        .alert("할일 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("'\(task.title)'을(를) 삭제하시겠습니까?")
        }
    }
    
    // MARK: - 서브뷰: 상태 Row
    
    private var statusRow: some View {
        HStack {
            // 완료 상태 뱃지
            HStack(spacing: 6) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .orange)
                Text(task.isCompleted ? "완료됨" : "진행 중")
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // 마감 상태 뱃지
            if !task.isCompleted {
                if task.isOverdue {
                    StatusBadge(text: "마감 지남", color: .red)
                } else if task.isDueSoon {
                    StatusBadge(text: "마감 임박", color: .orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 서브뷰: 마감일 섹션
    
    private var dueDateSection: some View {
        Group {
            if let dueDate = task.dueDate {
                DatePicker(
                    "마감일",
                    selection: Binding(
                        get: { dueDate },
                        set: { task.dueDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                Button("마감일 제거", role: .destructive) {
                    task.dueDate = nil
                }
            } else {
                Button("마감일 추가") {
                    task.dueDate = Date()
                }
            }
        }
    }
    
    // MARK: - 서브뷰: 카테고리 섹션
    
    private var categorySection: some View {
        Group {
            if categories.isEmpty {
                Text("사용 가능한 카테고리가 없습니다")
                    .foregroundStyle(.secondary)
            } else {
                Picker("카테고리", selection: $task.category) {
                    Text("없음")
                        .tag(nil as Category?)
                    
                    ForEach(categories) { category in
                        Label(category.name, systemImage: category.iconName)
                            .tag(category as Category?)
                    }
                }
            }
        }
    }
    
    // MARK: - 서브뷰: 정보 Row
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
    
    // MARK: - 헬퍼
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - 액션
    
    private func deleteTask() {
        modelContext.delete(task)
        dismiss()
    }
}

// MARK: - 상태 뱃지

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - 프리뷰

#Preview("진행 중") {
    NavigationStack {
        TaskDetailView(task: TaskItem(
            title: "SwiftData 문서 읽기",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            priority: 3,
            notes: "WWDC23 세션 영상도 함께 보기\n공식 문서 링크 확인"
        ))
    }
    .modelContainer(.preview)
}

#Preview("완료됨") {
    NavigationStack {
        let task = TaskItem(
            title: "완료된 할일",
            isCompleted: true,
            priority: 1
        )
        TaskDetailView(task: task)
    }
    .modelContainer(.preview)
}

#Preview("마감 지남") {
    NavigationStack {
        TaskDetailView(task: TaskItem(
            title: "마감 지난 할일",
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            priority: 2
        ))
    }
    .modelContainer(.preview)
}
