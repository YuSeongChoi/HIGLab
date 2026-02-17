import SwiftUI
import SwiftData

// MARK: - 메인 콘텐츠 뷰

/// 할일 목록을 표시하는 메인 뷰
/// - 필터링 (전체/미완료/완료)
/// - 카테고리별 필터
/// - 정렬 옵션
struct ContentView: View {
    // MARK: - 환경 & 쿼리
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \TaskItem.createdAt, order: .reverse)
    private var allTasks: [TaskItem]
    
    @Query(sort: \Category.order)
    private var categories: [Category]
    
    // MARK: - 상태
    
    @State private var showingAddTask = false
    @State private var selectedFilter: TaskFilter = .pending
    @State private var selectedCategory: Category?
    @State private var searchText = ""
    
    // MARK: - 필터링된 할일
    
    private var filteredTasks: [TaskItem] {
        var tasks = allTasks
        
        // 완료 상태 필터
        switch selectedFilter {
        case .all:
            break
        case .pending:
            tasks = tasks.filter { !$0.isCompleted }
        case .completed:
            tasks = tasks.filter { $0.isCompleted }
        }
        
        // 카테고리 필터
        if let category = selectedCategory {
            tasks = tasks.filter { $0.category?.persistentModelID == category.persistentModelID }
        }
        
        // 검색 필터
        if !searchText.isEmpty {
            tasks = tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        return tasks
    }
    
    // MARK: - 뷰 본문
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 필터 피커
                filterPicker
                
                // 카테고리 스크롤
                categoryScroll
                
                // 할일 목록 또는 빈 상태
                if filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    taskList
                }
            }
            .navigationTitle("TaskMaster")
            .searchable(text: $searchText, prompt: "할일 검색")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("완료된 항목 삭제", role: .destructive) {
                            deleteCompletedTasks()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
    
    // MARK: - 서브뷰: 필터 피커
    
    private var filterPicker: some View {
        Picker("필터", selection: $selectedFilter) {
            ForEach(TaskFilter.allCases) { filter in
                Text(filter.name).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - 서브뷰: 카테고리 스크롤
    
    private var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "전체" 버튼
                CategoryChip(
                    name: "전체",
                    color: .gray,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                // 각 카테고리 버튼
                ForEach(categories) { category in
                    CategoryChip(
                        name: category.name,
                        color: category.color,
                        count: category.pendingTaskCount,
                        isSelected: selectedCategory?.persistentModelID == category.persistentModelID
                    ) {
                        if selectedCategory?.persistentModelID == category.persistentModelID {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - 서브뷰: 할일 목록
    
    private var taskList: some View {
        List {
            ForEach(filteredTasks) { task in
                NavigationLink {
                    TaskDetailView(task: task)
                } label: {
                    TaskRowView(task: task)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteTask(task)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        task.toggleCompletion()
                    } label: {
                        Label(
                            task.isCompleted ? "미완료" : "완료",
                            systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                        )
                    }
                    .tint(task.isCompleted ? .orange : .green)
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - 서브뷰: 빈 상태
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(emptyStateTitle, systemImage: emptyStateIcon)
        } description: {
            Text(emptyStateDescription)
        } actions: {
            if selectedFilter != .completed {
                Button("새 할일 추가") {
                    showingAddTask = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var emptyStateTitle: String {
        if !searchText.isEmpty { return "검색 결과 없음" }
        switch selectedFilter {
        case .all: return "할일이 없습니다"
        case .pending: return "미완료 할일이 없습니다"
        case .completed: return "완료된 할일이 없습니다"
        }
    }
    
    private var emptyStateIcon: String {
        if !searchText.isEmpty { return "magnifyingglass" }
        switch selectedFilter {
        case .all: return "checklist"
        case .pending: return "checkmark.circle"
        case .completed: return "tray"
        }
    }
    
    private var emptyStateDescription: String {
        if !searchText.isEmpty { return "다른 검색어를 시도해보세요" }
        switch selectedFilter {
        case .all: return "새 할일을 추가해보세요"
        case .pending: return "모든 할일을 완료했습니다! 🎉"
        case .completed: return "완료된 할일이 여기에 표시됩니다"
        }
    }
    
    // MARK: - 액션
    
    private func deleteTask(_ task: TaskItem) {
        withAnimation {
            modelContext.delete(task)
        }
    }
    
    private func deleteCompletedTasks() {
        withAnimation {
            DataService.shared.deleteCompletedTasks(from: modelContext)
        }
    }
}

// MARK: - 필터 열거형

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case pending = "미완료"
    case completed = "완료"
    
    var id: String { rawValue }
    var name: String { rawValue }
}

// MARK: - 카테고리 칩

struct CategoryChip: View {
    let name: String
    let color: Color
    var count: Int = 0
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? .white.opacity(0.3) : color.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color : color.opacity(0.1))
            .foregroundStyle(isSelected ? .white : color)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .modelContainer(.preview)
}
