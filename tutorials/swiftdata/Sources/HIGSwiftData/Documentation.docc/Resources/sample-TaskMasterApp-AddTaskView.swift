import SwiftUI
import SwiftData

// MARK: - 할일 추가 뷰

/// 새로운 할일을 추가하는 Sheet 뷰
/// - 제목 입력 (필수)
/// - 마감일 설정 (선택)
/// - 우선순위 선택
/// - 카테고리 선택
/// - 메모 입력
struct AddTaskView: View {
    // MARK: - 환경
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Category.order)
    private var categories: [Category]
    
    // MARK: - 상태
    
    @State private var title = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var priority: TaskPriority = .none
    @State private var selectedCategory: Category?
    @State private var notes = ""
    
    @FocusState private var isTitleFocused: Bool
    
    // MARK: - 유효성 검사
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - 뷰 본문
    
    var body: some View {
        NavigationStack {
            Form {
                // 제목 섹션
                Section {
                    TextField("할일 제목", text: $title)
                        .focused($isTitleFocused)
                } header: {
                    Text("제목")
                } footer: {
                    if title.isEmpty {
                        Text("제목을 입력해주세요")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 마감일 섹션
                Section("마감일") {
                    Toggle("마감일 설정", isOn: $hasDueDate.animation())
                    
                    if hasDueDate {
                        DatePicker(
                            "마감일",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        
                        // 빠른 선택 버튼
                        quickDatePicker
                    }
                }
                
                // 우선순위 섹션
                Section("우선순위") {
                    Picker("우선순위", selection: $priority) {
                        ForEach(TaskPriority.allCases) { p in
                            Label(p.name, systemImage: p.symbol)
                                .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 카테고리 섹션
                Section("카테고리") {
                    if categories.isEmpty {
                        Text("카테고리가 없습니다")
                            .foregroundStyle(.secondary)
                    } else {
                        categoryPicker
                    }
                }
                
                // 메모 섹션
                Section("메모") {
                    TextField("메모 (선택)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("새 할일")
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
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                isTitleFocused = true
            }
        }
    }
    
    // MARK: - 서브뷰: 빠른 날짜 선택
    
    private var quickDatePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                QuickDateButton(title: "오늘", date: Date()) { dueDate = $0 }
                QuickDateButton(title: "내일", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!) { dueDate = $0 }
                QuickDateButton(title: "다음 주", date: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!) { dueDate = $0 }
                QuickDateButton(title: "다음 달", date: Calendar.current.date(byAdding: .month, value: 1, to: Date())!) { dueDate = $0 }
            }
        }
    }
    
    // MARK: - 서브뷰: 카테고리 선택
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "없음" 옵션
                CategorySelectButton(
                    name: "없음",
                    color: .gray,
                    iconName: "minus.circle",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                // 카테고리 목록
                ForEach(categories) { category in
                    CategorySelectButton(
                        name: category.name,
                        color: category.color,
                        iconName: category.iconName,
                        isSelected: selectedCategory?.persistentModelID == category.persistentModelID
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - 액션
    
    private func addTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let task = TaskItem(
            title: trimmedTitle,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority.rawValue,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory
        )
        
        modelContext.insert(task)
        dismiss()
    }
}

// MARK: - 빠른 날짜 버튼

struct QuickDateButton: View {
    let title: String
    let date: Date
    let action: (Date) -> Void
    
    var body: some View {
        Button {
            action(date)
        } label: {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.1))
                .foregroundStyle(.accent)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 카테고리 선택 버튼

struct CategorySelectButton: View {
    let name: String
    let color: Color
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : color.opacity(0.1))
            .foregroundStyle(isSelected ? .white : color)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? color : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 프리뷰

#Preview {
    AddTaskView()
        .modelContainer(.preview)
}
