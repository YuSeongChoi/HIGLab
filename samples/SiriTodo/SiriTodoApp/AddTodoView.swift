import SwiftUI
import AppIntents

// MARK: - 할일 추가 뷰
/// 새 할일을 추가하는 시트 화면
/// 제목, 메모, 우선순위, 마감일, 태그 설정 가능
struct AddTodoView: View {
    
    // MARK: - 환경
    
    @EnvironmentObject var store: TodoStore
    @EnvironmentObject var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 상태
    
    @State private var title = ""
    @State private var notes = ""
    @State private var priority: Priority = .normal
    @State private var dueDatePreset: DueDatePreset = .none
    @State private var selectedTagIds: Set<UUID> = []
    @State private var showingCustomDate = false
    @State private var customDate = Date()
    
    @FocusState private var focusedField: Field?
    
    // MARK: - 필드 열거형
    
    private enum Field {
        case title
        case notes
    }
    
    // MARK: - 계산 속성
    
    /// 제목이 유효한지 확인
    private var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// 마감일 계산
    private var dueDate: Date? {
        if showingCustomDate {
            return customDate
        }
        return dueDatePreset.date
    }
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: 기본 정보
                basicInfoSection
                
                // MARK: 우선순위
                prioritySection
                
                // MARK: 마감일
                dueDateSection
                
                // MARK: 태그
                tagSection
                
                // MARK: 빠른 추가 예시
                if title.isEmpty {
                    quickAddSection
                }
                
                // MARK: Siri 팁
                siriTipSection
            }
            .navigationTitle("새 할일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear {
                focusedField = .title
            }
        }
    }
    
    // MARK: - 기본 정보 섹션
    
    private var basicInfoSection: some View {
        Section {
            // 제목 입력
            TextField("할일 제목", text: $title)
                .focused($focusedField, equals: .title)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .notes
                }
            
            // 메모 입력
            TextField("메모 (선택)", text: $notes, axis: .vertical)
                .focused($focusedField, equals: .notes)
                .lineLimit(3...6)
        } header: {
            Text("할일 내용")
        } footer: {
            Text("Siri에게 \"[제목] 할일에 추가해줘\"라고 말해도 됩니다")
        }
    }
    
    // MARK: - 우선순위 섹션
    
    private var prioritySection: some View {
        Section("우선순위") {
            Picker("우선순위", selection: $priority) {
                ForEach(Priority.allCases, id: \.self) { p in
                    Label {
                        Text(p.displayName)
                    } icon: {
                        Text(p.emoji)
                    }
                    .tag(p)
                }
            }
            .pickerStyle(.segmented)
            
            // 우선순위 설명
            HStack {
                Text(priority.emoji)
                Text(priorityDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    /// 우선순위 설명
    private var priorityDescription: String {
        switch priority {
        case .low: return "나중에 해도 괜찮은 일"
        case .normal: return "일반적인 할일"
        case .high: return "빨리 처리해야 할 일"
        case .urgent: return "지금 당장 해야 할 일!"
        }
    }
    
    // MARK: - 마감일 섹션
    
    private var dueDateSection: some View {
        Section("마감일") {
            // 프리셋 선택
            if !showingCustomDate {
                Picker("마감일", selection: $dueDatePreset) {
                    ForEach(DueDatePreset.allCases, id: \.self) { preset in
                        Text(presetDisplayName(preset)).tag(preset)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // 직접 날짜 선택 토글
            Toggle("직접 날짜 선택", isOn: $showingCustomDate)
            
            // 날짜 피커
            if showingCustomDate {
                DatePicker(
                    "마감일",
                    selection: $customDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
            }
        }
    }
    
    /// 프리셋 표시 이름
    private func presetDisplayName(_ preset: DueDatePreset) -> String {
        switch preset {
        case .none: return "없음"
        case .today: return "오늘"
        case .tomorrow: return "내일"
        case .thisWeekend: return "이번 주말"
        case .nextWeek: return "다음 주"
        case .nextMonth: return "다음 달"
        }
    }
    
    // MARK: - 태그 섹션
    
    private var tagSection: some View {
        Section("태그") {
            ForEach(tagStore.tags) { tag in
                HStack {
                    Circle()
                        .fill(tag.color)
                        .frame(width: 12, height: 12)
                    
                    Text(tag.name)
                    
                    Spacer()
                    
                    if selectedTagIds.contains(tag.id) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedTagIds.contains(tag.id) {
                        selectedTagIds.remove(tag.id)
                    } else {
                        selectedTagIds.insert(tag.id)
                    }
                }
            }
            
            if tagStore.tags.isEmpty {
                Text("태그가 없습니다")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 빠른 추가 예시
    
    private var quickAddSection: some View {
        Section("예시") {
            ForEach(quickAddExamples, id: \.self) { example in
                Button {
                    title = example
                } label: {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text(example)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
    
    /// 빠른 추가 예시 목록
    private let quickAddExamples = [
        "장보기",
        "이메일 확인하기",
        "운동 30분",
        "책 읽기",
        "프로젝트 회의 준비"
    ]
    
    // MARK: - Siri 팁 섹션
    
    private var siriTipSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label("Siri로도 추가할 수 있어요", systemImage: "waveform")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\"긴급 할일 보고서 작성\"")
                    Text("\"오늘 할일 운동하기 추가\"")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
            .fontWeight(.semibold)
            .disabled(!isTitleValid)
        }
    }
    
    // MARK: - 할일 추가
    
    private func addTodo() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedTitle.isEmpty else { return }
        
        store.add(
            title: trimmedTitle,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            priority: priority,
            dueDate: dueDate,
            tagIds: Array(selectedTagIds)
        )
        
        dismiss()
    }
}

// MARK: - 할일 편집 뷰
/// 기존 할일을 편집하는 시트 화면
struct EditTodoView: View {
    
    // MARK: - 환경
    
    @EnvironmentObject var store: TodoStore
    @EnvironmentObject var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 바인딩
    
    let todoId: UUID
    
    // MARK: - 상태
    
    @State private var title = ""
    @State private var notes = ""
    @State private var priority: Priority = .normal
    @State private var dueDate: Date?
    @State private var selectedTagIds: Set<UUID> = []
    
    // MARK: - 초기화
    
    init(todo: TodoItem) {
        self.todoId = todo.id
        _title = State(initialValue: todo.title)
        _notes = State(initialValue: todo.notes ?? "")
        _priority = State(initialValue: todo.priority)
        _dueDate = State(initialValue: todo.dueDate)
        _selectedTagIds = State(initialValue: Set(todo.tagIds))
    }
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            Form {
                Section("할일 내용") {
                    TextField("제목", text: $title)
                    TextField("메모", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("우선순위") {
                    Picker("우선순위", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Label(p.displayName, systemImage: p.systemImageName)
                                .tag(p)
                        }
                    }
                }
                
                Section("마감일") {
                    Toggle("마감일 설정", isOn: .init(
                        get: { dueDate != nil },
                        set: { dueDate = $0 ? Date() : nil }
                    ))
                    
                    if dueDate != nil {
                        DatePicker(
                            "마감일",
                            selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
                
                Section("태그") {
                    ForEach(tagStore.tags) { tag in
                        HStack {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 12, height: 12)
                            Text(tag.name)
                            Spacer()
                            if selectedTagIds.contains(tag.id) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTagIds.contains(tag.id) {
                                selectedTagIds.remove(tag.id)
                            } else {
                                selectedTagIds.insert(tag.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveTodo()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    // MARK: - 저장
    
    private func saveTodo() {
        _ = store.update(id: todoId) { todo in
            todo.title = title.trimmingCharacters(in: .whitespaces)
            todo.notes = notes.isEmpty ? nil : notes
            todo.priority = priority
            todo.dueDate = dueDate
            todo.tagIds = Array(selectedTagIds)
        }
        dismiss()
    }
}

// MARK: - 프리뷰
#Preview("Add") {
    AddTodoView()
        .environmentObject(TodoStore.shared)
        .environmentObject(TagStore.shared)
}

#Preview("Edit") {
    EditTodoView(todo: TodoItem(title: "테스트 할일", priority: .high))
        .environmentObject(TodoStore.shared)
        .environmentObject(TagStore.shared)
}
