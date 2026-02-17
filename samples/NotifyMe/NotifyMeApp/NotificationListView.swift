import SwiftUI

// MARK: - 알림 목록 뷰
// 예약된 모든 알림을 카테고리별로 그룹화하여 표시합니다.
// 스와이프로 삭제, 토글로 활성화/비활성화, 탭으로 편집이 가능합니다.

struct NotificationListView: View {
    @EnvironmentObject var notificationStore: NotificationStore
    @Binding var showingAddSheet: Bool
    
    @State private var selectedItem: NotificationItem?
    @State private var searchText = ""
    @State private var filterCategory: NotificationCategory?
    
    /// 필터링 및 검색된 알림 목록
    private var filteredNotifications: [NotificationItem] {
        var result = notificationStore.notifications
        
        // 카테고리 필터
        if let category = filterCategory {
            result = result.filter { $0.category == category }
        }
        
        // 검색 필터
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.body.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 날짜순 정렬
        return result.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    /// 카테고리별 그룹화
    private var groupedNotifications: [NotificationCategory: [NotificationItem]] {
        Dictionary(grouping: filteredNotifications, by: { $0.category })
    }
    
    var body: some View {
        List {
            // 카테고리 필터 섹션
            categoryFilterSection
            
            // 알림 목록
            if filteredNotifications.isEmpty {
                emptyStateView
            } else {
                notificationSections
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "알림 검색")
        .navigationTitle("알림")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Button("테스트 알림 보내기", systemImage: "bell.badge") {
                        sendTestNotification()
                    }
                    
                    Divider()
                    
                    Button("모든 알림 활성화", systemImage: "bell.fill") {
                        toggleAllNotifications(enabled: true)
                    }
                    
                    Button("모든 알림 비활성화", systemImage: "bell.slash") {
                        toggleAllNotifications(enabled: false)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            NotificationDetailView(mode: .edit(item)) { updatedItem in
                notificationStore.updateNotification(updatedItem)
            }
        }
    }
    
    // MARK: - 카테고리 필터 섹션
    
    private var categoryFilterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // 전체 필터
                    FilterChip(
                        title: "전체",
                        symbol: "square.grid.2x2",
                        isSelected: filterCategory == nil,
                        color: .gray
                    ) {
                        filterCategory = nil
                    }
                    
                    // 카테고리별 필터
                    ForEach(NotificationCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            symbol: category.symbol,
                            isSelected: filterCategory == category,
                            color: categoryColor(category)
                        ) {
                            filterCategory = filterCategory == category ? nil : category
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
    }
    
    // MARK: - 알림 섹션
    
    private var notificationSections: some View {
        ForEach(NotificationCategory.allCases, id: \.self) { category in
            if let items = groupedNotifications[category], !items.isEmpty {
                Section {
                    ForEach(items) { item in
                        NotificationRow(
                            item: item,
                            onToggle: { isEnabled in
                                notificationStore.toggleNotification(id: item.id, isEnabled: isEnabled)
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = item
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                notificationStore.deleteNotification(id: item.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                sendNotificationNow(item)
                            } label: {
                                Label("지금 보내기", systemImage: "bell.badge")
                            }
                            .tint(.blue)
                        }
                    }
                } header: {
                    Label(category.displayName, systemImage: category.symbol)
                        .foregroundStyle(categoryColor(category))
                }
            }
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyStateView: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: searchText.isEmpty ? "bell.slash" : "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
                
                Text(searchText.isEmpty ? "예약된 알림이 없습니다" : "검색 결과가 없습니다")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                if searchText.isEmpty {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("새 알림 추가", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        }
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Helpers
    
    private func categoryColor(_ category: NotificationCategory) -> Color {
        switch category {
        case .reminder: .blue
        case .health: .red
        case .work: .purple
        case .social: .green
        case .location: .orange
        }
    }
    
    private func sendTestNotification() {
        let testItem = NotificationItem(
            title: "테스트 알림 🔔",
            body: "NotifyMe에서 보낸 테스트 알림입니다.",
            scheduledDate: Date(),
            category: .reminder
        )
        
        Task {
            try? await NotificationService.shared.sendImmediateNotification(testItem)
        }
    }
    
    private func sendNotificationNow(_ item: NotificationItem) {
        Task {
            try? await NotificationService.shared.sendImmediateNotification(item)
        }
    }
    
    private func toggleAllNotifications(enabled: Bool) {
        for item in notificationStore.notifications {
            notificationStore.toggleNotification(id: item.id, isEnabled: enabled)
        }
    }
}

// MARK: - 알림 행 뷰

struct NotificationRow: View {
    let item: NotificationItem
    let onToggle: (Bool) -> Void
    
    @State private var isEnabled: Bool
    
    init(item: NotificationItem, onToggle: @escaping (Bool) -> Void) {
        self.item = item
        self.onToggle = onToggle
        self._isEnabled = State(initialValue: item.isEnabled)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 상태 인디케이터
            Circle()
                .fill(isEnabled ? categoryColor : Color.gray.opacity(0.3))
                .frame(width: 10, height: 10)
            
            // 내용
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(isEnabled ? .primary : .secondary)
                
                if !item.body.isEmpty {
                    Text(item.body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // 시간 정보
                HStack(spacing: 8) {
                    Label(formattedDate, systemImage: "clock")
                    
                    if item.repeatInterval != .none {
                        Label(item.repeatInterval.rawValue, systemImage: item.repeatInterval.symbol)
                    }
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            // 토글
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .onChange(of: isEnabled) { _, newValue in
                    onToggle(newValue)
                }
        }
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        switch item.category {
        case .reminder: .blue
        case .health: .red
        case .work: .purple
        case .social: .green
        case .location: .orange
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(item.scheduledDate) {
            formatter.dateFormat = "오늘 HH:mm"
        } else if Calendar.current.isDateInTomorrow(item.scheduledDate) {
            formatter.dateFormat = "내일 HH:mm"
        } else {
            formatter.dateFormat = "M/d HH:mm"
        }
        
        return formatter.string(from: item.scheduledDate)
    }
}

// MARK: - 필터 칩

struct FilterChip: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.2) : Color(.systemGray6))
            .foregroundStyle(isSelected ? color : .primary)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NotificationListView(showingAddSheet: .constant(false))
            .environmentObject(NotificationStore())
    }
}
