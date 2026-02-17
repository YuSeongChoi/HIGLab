import SwiftUI

// MARK: - 알림 히스토리 뷰
// 수신된 알림 기록을 시간순으로 표시합니다.
// 읽음/읽지 않음 상태, 카테고리별 필터링, 삭제 기능을 제공합니다.

struct HistoryView: View {
    @EnvironmentObject var historyStore: NotificationHistoryStore
    
    @State private var selectedFilter: HistoryFilter = .all
    @State private var showingClearConfirmation = false
    
    enum HistoryFilter: String, CaseIterable {
        case all = "전체"
        case unread = "읽지 않음"
        case today = "오늘"
        
        var symbol: String {
            switch self {
            case .all: "tray.full"
            case .unread: "circle.badge"
            case .today: "calendar"
            }
        }
    }
    
    /// 필터링된 히스토리
    private var filteredHistory: [NotificationHistoryItem] {
        switch selectedFilter {
        case .all:
            return historyStore.history
        case .unread:
            return historyStore.history.filter { !$0.wasOpened }
        case .today:
            return historyStore.history.filter {
                Calendar.current.isDateInToday($0.deliveredAt)
            }
        }
    }
    
    /// 날짜별 그룹화
    private var groupedHistory: [(key: String, items: [NotificationHistoryItem])] {
        let grouped = Dictionary(grouping: filteredHistory) { item in
            dateGroupKey(for: item.deliveredAt)
        }
        
        // 날짜순 정렬 (최신 먼저)
        return grouped.sorted { $0.key > $1.key }
            .map { (key: dateDisplayString(for: $0.key), items: $0.value) }
    }
    
    var body: some View {
        List {
            // 필터 섹션
            filterSection
            
            // 히스토리 목록
            if filteredHistory.isEmpty {
                emptyStateView
            } else {
                historyContent
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("히스토리")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("모두 읽음으로 표시", systemImage: "checkmark.circle") {
                        markAllAsRead()
                    }
                    
                    Divider()
                    
                    Button("전체 히스토리 삭제", systemImage: "trash", role: .destructive) {
                        showingClearConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            "모든 히스토리를 삭제하시겠습니까?",
            isPresented: $showingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("전체 삭제", role: .destructive) {
                historyStore.clearHistory()
            }
        } message: {
            Text("이 작업은 되돌릴 수 없습니다.")
        }
    }
    
    // MARK: - 필터 섹션
    
    private var filterSection: some View {
        Section {
            Picker("필터", selection: $selectedFilter) {
                ForEach(HistoryFilter.allCases, id: \.self) { filter in
                    Label(filter.rawValue, systemImage: filter.symbol)
                        .tag(filter)
                }
            }
            .pickerStyle(.segmented)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
    
    // MARK: - 히스토리 콘텐츠
    
    private var historyContent: some View {
        ForEach(groupedHistory, id: \.key) { group in
            Section {
                ForEach(group.items) { item in
                    HistoryRow(item: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                historyStore.removeFromHistory(id: item.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                historyStore.markAsOpened(id: item.id)
                            } label: {
                                Label("읽음", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                }
            } header: {
                Text(group.key)
            }
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyStateView: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
                
                Text(emptyStateMessage)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text("알림을 받으면 여기에 기록됩니다")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        }
        .listRowBackground(Color.clear)
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all: "알림 히스토리가 없습니다"
        case .unread: "읽지 않은 알림이 없습니다"
        case .today: "오늘 받은 알림이 없습니다"
        }
    }
    
    // MARK: - Helpers
    
    private func dateGroupKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func dateDisplayString(for key: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: key) else { return key }
        
        if Calendar.current.isDateInToday(date) {
            return "오늘"
        } else if Calendar.current.isDateInYesterday(date) {
            return "어제"
        } else {
            formatter.dateFormat = "M월 d일 (E)"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        }
    }
    
    private func markAllAsRead() {
        for item in historyStore.history where !item.wasOpened {
            historyStore.markAsOpened(id: item.id)
        }
    }
}

// MARK: - 히스토리 행

struct HistoryRow: View {
    let item: NotificationHistoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 읽음 상태 인디케이터
            Circle()
                .fill(item.wasOpened ? Color.clear : Color.blue)
                .frame(width: 8, height: 8)
            
            // 카테고리 아이콘
            Image(systemName: item.category.symbol)
                .font(.title3)
                .foregroundStyle(categoryColor)
                .frame(width: 32)
            
            // 내용
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(item.wasOpened ? .secondary : .primary)
                    
                    Spacer()
                    
                    Text(item.relativeTimeString)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                if !item.body.isEmpty {
                    Text(item.body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                // 카테고리 태그
                Text(item.category.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(categoryColor.opacity(0.15))
                    .foregroundStyle(categoryColor)
                    .clipShape(Capsule())
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
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject(NotificationHistoryStore.shared)
    }
}
