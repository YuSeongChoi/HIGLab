import SwiftUI
import EventKit

// MARK: - 리마인더 목록 뷰
/// 리마인더를 필터링하고 관리하는 뷰
struct ReminderListView: View {
    @EnvironmentObject var eventKitManager: EventKitManager
    
    @State private var selectedFilter: ReminderFilter = .all
    @State private var selectedListId: String? = nil
    @State private var showingNewReminder = false
    @State private var selectedReminder: ReminderItem?
    @State private var showingListPicker = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 필터 선택
                filterScrollView
                
                // 리마인더 목록
                reminderListSection
            }
            .navigationTitle("미리알림")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingListPicker = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedReminder = nil
                        showingNewReminder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "검색")
            .sheet(isPresented: $showingNewReminder) {
                ReminderDetailView(
                    reminder: nil,
                    onSave: { _ in
                        Task {
                            await loadReminders()
                        }
                    }
                )
            }
            .sheet(item: $selectedReminder) { reminder in
                ReminderDetailView(
                    reminder: reminder,
                    onSave: { _ in
                        Task {
                            await loadReminders()
                        }
                    }
                )
            }
            .sheet(isPresented: $showingListPicker) {
                ReminderListPickerView(selectedListId: $selectedListId)
            }
            .task {
                await loadReminders()
            }
            .refreshable {
                await loadReminders()
            }
            .onChange(of: selectedFilter) {
                Task {
                    await loadReminders()
                }
            }
            .onChange(of: selectedListId) {
                Task {
                    await loadReminders()
                }
            }
        }
    }
    
    // MARK: - 필터 스크롤 뷰
    private var filterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ReminderFilter.allCases, id: \.self) { filter in
                    FilterChipView(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - 리마인더 목록 섹션
    @ViewBuilder
    private var reminderListSection: some View {
        if eventKitManager.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredReminders.isEmpty {
            ContentUnavailableView(
                emptyStateTitle,
                systemImage: emptyStateSymbol,
                description: Text(emptyStateDescription)
            )
        } else {
            List {
                ForEach(filteredReminders) { reminder in
                    ReminderRowView(
                        reminder: reminder,
                        onToggle: {
                            Task {
                                await toggleReminder(reminder)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedReminder = reminder
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                await deleteReminder(reminder)
                            }
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    // MARK: - 필터링된 리마인더
    private var filteredReminders: [ReminderItem] {
        var result = eventKitManager.reminders
        
        // 검색어 필터링
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return result
    }
    
    // MARK: - 빈 상태 텍스트
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return "미리알림 없음"
        case .today: return "오늘 미리알림 없음"
        case .scheduled: return "예정된 미리알림 없음"
        case .completed: return "완료된 항목 없음"
        case .flagged: return "중요 항목 없음"
        }
    }
    
    private var emptyStateSymbol: String {
        selectedFilter.symbolName
    }
    
    private var emptyStateDescription: String {
        switch selectedFilter {
        case .all: return "새로운 미리알림을 추가하세요"
        case .today: return "오늘 기한인 미리알림이 없습니다"
        case .scheduled: return "예정된 미리알림이 없습니다"
        case .completed: return "완료된 항목이 없습니다"
        case .flagged: return "높은 우선순위 항목이 없습니다"
        }
    }
    
    // MARK: - 리마인더 로드
    private func loadReminders() async {
        let lists = selectedListId.map { [$0] }
        await eventKitManager.loadReminders(for: selectedFilter, lists: lists)
    }
    
    // MARK: - 리마인더 토글
    private func toggleReminder(_ reminder: ReminderItem) async {
        do {
            try await eventKitManager.toggleReminderCompletion(reminder)
            await loadReminders()
        } catch {
            print("Toggle error: \(error)")
        }
    }
    
    // MARK: - 리마인더 삭제
    private func deleteReminder(_ reminder: ReminderItem) async {
        do {
            try await eventKitManager.deleteReminder(reminder)
            await loadReminders()
        } catch {
            print("Delete error: \(error)")
        }
    }
}

// MARK: - 필터 칩 뷰
struct FilterChipView: View {
    let filter: ReminderFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.symbolName)
                    .font(.caption)
                
                Text(filter.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - 리마인더 행 뷰
struct ReminderRowView: View {
    let reminder: ReminderItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 완료 체크박스
            Button(action: onToggle) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(reminder.isCompleted ? .green : Color(cgColor: reminder.listColor ?? CGColor(gray: 0.5, alpha: 1)))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                // 제목
                HStack(spacing: 6) {
                    Text(reminder.title)
                        .font(.body)
                        .strikethrough(reminder.isCompleted)
                        .foregroundStyle(reminder.isCompleted ? .secondary : .primary)
                    
                    // 우선순위 표시
                    if reminder.priority != .none {
                        Image(systemName: reminder.priority.symbolName)
                            .font(.caption)
                            .foregroundStyle(priorityColor)
                    }
                }
                
                // 기한 및 메모
                HStack(spacing: 8) {
                    if let dueDate = reminder.dueDate {
                        Label(dueDateText(dueDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(dueDateColor(dueDate))
                    }
                    
                    if let notes = reminder.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    // 반복 표시
                    if reminder.recurrenceRule != nil {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 알림 표시
                    if !reminder.alarms.isEmpty {
                        Image(systemName: "bell")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 목록 색상 표시
            Circle()
                .fill(Color(cgColor: reminder.listColor ?? CGColor(gray: 0.5, alpha: 1)))
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 우선순위 색상
    private var priorityColor: Color {
        switch reminder.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        case .none: return .clear
        }
    }
    
    // MARK: - 기한 텍스트
    private func dueDateText(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "오늘 \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            return "내일"
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M/d"
            return formatter.string(from: date)
        }
    }
    
    // MARK: - 기한 색상
    private func dueDateColor(_ date: Date) -> Color {
        if date < Date() && !reminder.isCompleted {
            return .red
        } else if Calendar.current.isDateInToday(date) {
            return .orange
        }
        return .secondary
    }
}

// MARK: - 리마인더 목록 선택 뷰
struct ReminderListPickerView: View {
    @EnvironmentObject var eventKitManager: EventKitManager
    @Binding var selectedListId: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // 전체 선택
                Button {
                    selectedListId = nil
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "tray.full")
                            .foregroundStyle(.blue)
                        
                        Text("전체 목록")
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if selectedListId == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                // 개별 목록
                ForEach(eventKitManager.reminderLists) { list in
                    Button {
                        selectedListId = list.id
                        dismiss()
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color(cgColor: list.color))
                                .frame(width: 12, height: 12)
                            
                            Text(list.title)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            // 미완료 개수
                            if list.incompleteCount > 0 {
                                Text("\(list.incompleteCount)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(Capsule())
                            }
                            
                            if selectedListId == list.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("목록 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 리마인더 상세/편집 뷰
struct ReminderDetailView: View {
    @EnvironmentObject var eventKitManager: EventKitManager
    @Environment(\.dismiss) private var dismiss
    
    let originalReminder: ReminderItem?
    let onSave: ((ReminderItem) -> Void)?
    
    // 폼 상태
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var priority: ReminderPriority = .none
    @State private var selectedListId: String = ""
    @State private var hasRecurrence: Bool = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .daily
    @State private var recurrenceInterval: Int = 1
    @State private var alarms: [ReminderAlarm] = []
    
    // UI 상태
    @State private var showingDeleteConfirmation = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var isEditing: Bool {
        originalReminder != nil
    }
    
    init(reminder: ReminderItem?, onSave: ((ReminderItem) -> Void)? = nil) {
        self.originalReminder = reminder
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 기본 정보
                Section {
                    TextField("제목", text: $title)
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
                
                // 기한 설정
                Section {
                    Toggle("기한", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("날짜 및 시간", selection: $dueDate)
                    }
                }
                
                // 우선순위
                Section {
                    Picker("우선순위", selection: $priority) {
                        ForEach(ReminderPriority.allCases, id: \.self) { p in
                            Text(p.displayText).tag(p)
                        }
                    }
                }
                
                // 반복
                if hasDueDate {
                    Section {
                        Toggle("반복", isOn: $hasRecurrence)
                        
                        if hasRecurrence {
                            Picker("주기", selection: $recurrenceFrequency) {
                                ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                                    Text(freq.rawValue).tag(freq)
                                }
                            }
                            
                            Stepper("간격: \(recurrenceInterval)", value: $recurrenceInterval, in: 1...99)
                        }
                    }
                }
                
                // 목록 선택
                Section {
                    Picker("목록", selection: $selectedListId) {
                        ForEach(editableLists) { list in
                            HStack {
                                Circle()
                                    .fill(Color(cgColor: list.color))
                                    .frame(width: 10, height: 10)
                                Text(list.title)
                            }
                            .tag(list.id)
                        }
                    }
                }
                
                // 삭제 버튼
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("미리알림 삭제")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "미리알림 편집" : "새로운 미리알림")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "저장" : "추가") {
                        Task { await saveReminder() }
                    }
                    .disabled(title.isEmpty || isLoading)
                }
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") { errorMessage = nil }
            } message: {
                if let errorMessage { Text(errorMessage) }
            }
            .confirmationDialog("미리알림 삭제", isPresented: $showingDeleteConfirmation) {
                Button("삭제", role: .destructive) {
                    Task { await deleteReminder() }
                }
                Button("취소", role: .cancel) { }
            }
            .onAppear { setupInitialValues() }
        }
    }
    
    // MARK: - 편집 가능한 목록
    private var editableLists: [ReminderList] {
        eventKitManager.reminderLists.filter { $0.allowsModify }
    }
    
    // MARK: - 초기값 설정
    private func setupInitialValues() {
        if let reminder = originalReminder {
            title = reminder.title
            notes = reminder.notes ?? ""
            hasDueDate = reminder.dueDate != nil
            dueDate = reminder.dueDate ?? Date()
            priority = reminder.priority
            selectedListId = reminder.listIdentifier
            
            if let rule = reminder.recurrenceRule {
                hasRecurrence = true
                recurrenceFrequency = rule.frequency
                recurrenceInterval = rule.interval
            }
        } else {
            if let defaultList = eventKitManager.defaultReminderList() {
                selectedListId = defaultList.id
            } else if let firstList = editableLists.first {
                selectedListId = firstList.id
            }
        }
    }
    
    // MARK: - 저장
    private func saveReminder() async {
        isLoading = true
        defer { isLoading = false }
        
        let reminder = ReminderItem(
            title: title,
            notes: notes.isEmpty ? nil : notes,
            isCompleted: originalReminder?.isCompleted ?? false,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            listIdentifier: selectedListId,
            alarms: alarms,
            recurrenceRule: hasRecurrence ? RecurrenceRule(
                frequency: recurrenceFrequency,
                interval: recurrenceInterval
            ) : nil
        )
        
        do {
            if originalReminder != nil {
                try await eventKitManager.updateReminder(reminder)
            } else {
                try await eventKitManager.createReminder(reminder)
            }
            onSave?(reminder)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 삭제
    private func deleteReminder() async {
        guard let reminder = originalReminder else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await eventKitManager.deleteReminder(reminder)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - 미리보기
#Preview {
    ReminderListView()
        .environmentObject(EventKitManager.shared)
}
