import SwiftUI
import SwiftData

// 필터 기능이 있는 할 일 목록

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case pending = "할 일"
    case completed = "완료"
    
    var id: String { rawValue }
}

// MARK: - 컨테이너 뷰

struct FilteredTaskListContainer: View {
    @State private var selectedFilter: TaskFilter = .all
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 필터 세그먼트
                filterPicker
                
                // 필터에 따른 리스트
                FilteredTaskListView(
                    filter: selectedFilter,
                    searchText: searchText
                )
            }
            .navigationTitle("TaskMaster")
            .searchable(text: $searchText, prompt: "할 일 검색")
        }
    }
    
    private var filterPicker: some View {
        Picker("필터", selection: $selectedFilter) {
            ForEach(TaskFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

// MARK: - 필터 적용 리스트

struct FilteredTaskListView: View {
    let filter: TaskFilter
    let searchText: String
    
    @Query private var tasks: [TaskItem]
    @Environment(\.modelContext) private var context
    
    init(filter: TaskFilter, searchText: String) {
        self.filter = filter
        self.searchText = searchText
        
        // 동적 predicate 생성
        let predicate = FilteredTaskListView.buildPredicate(
            filter: filter,
            searchText: searchText
        )
        
        _tasks = Query(
            filter: predicate,
            sort: [
                SortDescriptor(\TaskItem.priority.rawValue, order: .reverse),
                SortDescriptor(\TaskItem.createdAt, order: .reverse)
            ],
            animation: .default
        )
    }
    
    var body: some View {
        Group {
            if tasks.isEmpty {
                emptyView
            } else {
                listView
            }
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label(emptyMessage, systemImage: emptyIcon)
        }
    }
    
    private var listView: some View {
        List {
            ForEach(tasks) { task in
                TaskRowView(task: task)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    context.delete(tasks[index])
                }
            }
        }
    }
    
    // MARK: - Predicate Builder
    
    private static func buildPredicate(
        filter: TaskFilter,
        searchText: String
    ) -> Predicate<TaskItem>? {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespaces)
        
        switch (filter, trimmedSearch.isEmpty) {
        case (.all, true):
            return nil
            
        case (.all, false):
            return #Predicate<TaskItem> { task in
                task.title.localizedStandardContains(trimmedSearch)
            }
            
        case (.pending, true):
            return #Predicate<TaskItem> { !$0.isCompleted }
            
        case (.pending, false):
            return #Predicate<TaskItem> { task in
                !task.isCompleted && task.title.localizedStandardContains(trimmedSearch)
            }
            
        case (.completed, true):
            return #Predicate<TaskItem> { $0.isCompleted }
            
        case (.completed, false):
            return #Predicate<TaskItem> { task in
                task.isCompleted && task.title.localizedStandardContains(trimmedSearch)
            }
        }
    }
    
    // MARK: - Helper
    
    private var emptyMessage: String {
        if !searchText.isEmpty {
            return "검색 결과가 없습니다"
        }
        switch filter {
        case .all: return "할 일이 없습니다"
        case .pending: return "할 일을 모두 완료했습니다! 🎉"
        case .completed: return "완료된 항목이 없습니다"
        }
    }
    
    private var emptyIcon: String {
        if !searchText.isEmpty { return "magnifyingglass" }
        switch filter {
        case .all: return "tray"
        case .pending: return "checkmark.circle"
        case .completed: return "archivebox"
        }
    }
}

#Preview {
    FilteredTaskListContainer()
        .modelContainer(.preview)
}
