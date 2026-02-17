import SwiftUI
import AppIntents

// MARK: - 메인 할일 목록 뷰
/// 할일 목록을 표시하고 관리하는 메인 화면
/// 미완료/완료 섹션으로 구분하여 표시
struct ContentView: View {
    
    // MARK: - 환경 객체
    
    @EnvironmentObject var store: TodoStore
    @EnvironmentObject var navigationManager: NavigationManager
    
    // MARK: - 상태
    
    @State private var showingAddSheet = false
    @State private var showingStatistics = false
    @State private var showingSettings = false
    @State private var searchText = ""
    @State private var selectedFilter: ContentFilter = .all
    @State private var showingSiriTip = true
    
    // MARK: - 계산 속성
    
    /// 필터링된 미완료 할일
    private var filteredIncompleteTodos: [TodoItem] {
        let incomplete = store.incompleteTodos
        return filterTodos(incomplete)
    }
    
    /// 필터링된 완료 할일
    private var filteredCompletedTodos: [TodoItem] {
        let completed = store.completedTodos
        return filterTodos(completed)
    }
    
    /// 검색 및 필터 적용
    private func filterTodos(_ todos: [TodoItem]) -> [TodoItem] {
        var result = todos
        
        // 검색어 필터
        if !searchText.isEmpty {
            result = result.filter { todo in
                todo.title.localizedCaseInsensitiveContains(searchText) ||
                (todo.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // 카테고리 필터
        switch selectedFilter {
        case .all:
            break
        case .today:
            result = result.filter { $0.isDueToday }
        case .urgent:
            result = result.filter { $0.priority == .urgent || $0.priority == .high }
        case .overdue:
            result = result.filter { $0.isOverdue }
        }
        
        // 우선순위순 정렬
        return result.sorted { $0.sortPriority > $1.sortPriority }
    }
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            Group {
                if store.todos.isEmpty && searchText.isEmpty {
                    emptyStateView
                } else {
                    todoListView
                }
            }
            .navigationTitle("할일 목록")
            .searchable(text: $searchText, prompt: "할일 검색")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingAddSheet) {
                AddTodoView()
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onChange(of: navigationManager.showingAddTodo) { _, newValue in
                showingAddSheet = newValue
            }
        }
    }
    
    // MARK: - 할일 목록 뷰
    
    @ViewBuilder
    private var todoListView: some View {
        List {
            // Siri 팁 (접을 수 있음)
            if showingSiriTip && searchText.isEmpty && selectedFilter == .all {
                Section {
                    SiriMiniTipView("\"할일에 장보기 추가해줘\"")
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
            }
            
            // 필터 피커
            if searchText.isEmpty {
                Section {
                    Picker("필터", selection: $selectedFilter) {
                        ForEach(ContentFilter.allCases) { filter in
                            Label(filter.title, systemImage: filter.icon)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }
            }
            
            // 미완료 섹션
            if !filteredIncompleteTodos.isEmpty {
                Section {
                    ForEach(filteredIncompleteTodos) { todo in
                        TodoRowView(todo: todo)
                            .swipeActions(edge: .leading) {
                                completeButton(for: todo)
                            }
                            .swipeActions(edge: .trailing) {
                                deleteButton(for: todo)
                                priorityMenu(for: todo)
                            }
                    }
                } header: {
                    HStack {
                        Text("진행 중")
                        Spacer()
                        Text("\(filteredIncompleteTodos.count)개")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // 완료 섹션
            if !filteredCompletedTodos.isEmpty && selectedFilter != .overdue {
                Section {
                    ForEach(filteredCompletedTodos) { todo in
                        TodoRowView(todo: todo)
                            .swipeActions(edge: .trailing) {
                                deleteButton(for: todo)
                                uncompleteButton(for: todo)
                            }
                    }
                } header: {
                    HStack {
                        Text("완료됨")
                        Spacer()
                        Text("\(filteredCompletedTodos.count)개")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.easeInOut, value: selectedFilter)
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("할일이 없습니다", systemImage: "checkmark.circle")
        } description: {
            Text("새 할일을 추가하거나\nSiri에게 \"할일 추가해줘\"라고 말해보세요")
        } actions: {
            Button {
                showingAddSheet = true
            } label: {
                Label("할일 추가", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 왼쪽: 통계 & 설정
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    showingStatistics = true
                } label: {
                    Label("통계", systemImage: "chart.pie")
                }
                
                Button {
                    showingSettings = true
                } label: {
                    Label("설정", systemImage: "gear")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    let deleted = store.deleteAllCompleted()
                    if deleted > 0 {
                        // 햅틱 피드백
                    }
                } label: {
                    Label("완료된 항목 정리", systemImage: "trash")
                }
                .disabled(store.completedTodos.isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        
        // 오른쪽: 추가 버튼
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    // MARK: - 스와이프 액션
    
    private func completeButton(for todo: TodoItem) -> some View {
        Button {
            withAnimation {
                store.complete(todo)
            }
        } label: {
            Label("완료", systemImage: "checkmark")
        }
        .tint(.green)
    }
    
    private func uncompleteButton(for todo: TodoItem) -> some View {
        Button {
            withAnimation {
                _ = store.uncomplete(id: todo.id)
            }
        } label: {
            Label("되돌리기", systemImage: "arrow.uturn.backward")
        }
        .tint(.orange)
    }
    
    private func deleteButton(for todo: TodoItem) -> some View {
        Button(role: .destructive) {
            withAnimation {
                store.delete(todo)
            }
        } label: {
            Label("삭제", systemImage: "trash")
        }
    }
    
    private func priorityMenu(for todo: TodoItem) -> some View {
        Menu {
            ForEach(Priority.allCases, id: \.self) { priority in
                Button {
                    _ = store.setPriority(id: todo.id, priority: priority)
                } label: {
                    Label(
                        priority.displayName,
                        systemImage: priority.systemImageName
                    )
                }
            }
        } label: {
            Label("우선순위", systemImage: "flag")
        }
        .tint(.blue)
    }
}

// MARK: - 콘텐츠 필터
enum ContentFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case today = "today"
    case urgent = "urgent"
    case overdue = "overdue"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .all: return "전체"
        case .today: return "오늘"
        case .urgent: return "긴급"
        case .overdue: return "지연"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .today: return "calendar"
        case .urgent: return "exclamationmark.circle"
        case .overdue: return "exclamationmark.triangle"
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
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if todo.isCompleted {
                        _ = store.uncomplete(id: todo.id)
                    } else {
                        store.complete(todo)
                    }
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(todo.isCompleted ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            
            // 할일 내용
            VStack(alignment: .leading, spacing: 4) {
                // 제목
                HStack(spacing: 6) {
                    Text(todo.title)
                        .strikethrough(todo.isCompleted)
                        .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                    
                    // 우선순위 표시 (보통 제외)
                    if todo.priority != .normal && !todo.isCompleted {
                        Text(todo.priority.emoji)
                            .font(.caption)
                    }
                }
                
                // 부가 정보
                HStack(spacing: 8) {
                    // 마감일
                    if let dueDate = todo.dueDateInfo {
                        Label(dueDate.shortDateString, systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(todo.isOverdue ? .red : .secondary)
                    }
                    
                    // 완료 시간
                    if let completedAt = todo.completedAt {
                        Label {
                            Text(completedAt, style: .relative)
                        } icon: {
                            Image(systemName: "checkmark")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    
                    // 메모 있음 표시
                    if todo.notes != nil && !(todo.notes?.isEmpty ?? true) {
                        Image(systemName: "note.text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 기한 지남 표시
            if todo.isOverdue && !todo.isCompleted {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - 프리뷰
#Preview {
    ContentView()
        .environmentObject(TodoStore.shared)
        .environmentObject(TagStore.shared)
        .environmentObject(NavigationManager.shared)
}
