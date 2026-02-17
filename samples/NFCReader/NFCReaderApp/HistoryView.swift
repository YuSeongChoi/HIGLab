import SwiftUI

// MARK: - 히스토리 뷰

/// 스캔 히스토리를 표시하는 화면
struct HistoryView: View {
    @EnvironmentObject var historyManager: ScanHistoryManager
    
    /// 선택된 필터 기간
    @State private var selectedPeriod: ScanHistoryManager.DatePeriod = .all
    
    /// 즐겨찾기만 표시 여부
    @State private var showFavoritesOnly = false
    
    /// 검색 텍스트
    @State private var searchText = ""
    
    /// 선택된 항목 (상세 보기용)
    @State private var selectedItem: ScanHistoryItem?
    
    /// 삭제 확인 알림 표시 여부
    @State private var showDeleteAlert = false
    
    /// 통계 시트 표시 여부
    @State private var showStatistics = false
    
    var body: some View {
        NavigationStack {
            Group {
                if historyManager.items.isEmpty {
                    emptyStateView
                } else {
                    historyList
                }
            }
            .background(Color.nfcBackground)
            .navigationTitle("히스토리")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showStatistics = true
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // 즐겨찾기 필터
                        Button {
                            showFavoritesOnly.toggle()
                        } label: {
                            Label(
                                showFavoritesOnly ? "전체 보기" : "즐겨찾기만",
                                systemImage: showFavoritesOnly ? "star.slash" : "star.fill"
                            )
                        }
                        
                        Divider()
                        
                        // 기간 필터
                        ForEach(ScanHistoryManager.DatePeriod.allCases, id: \.self) { period in
                            Button {
                                selectedPeriod = period
                            } label: {
                                Label(
                                    period.rawValue,
                                    systemImage: selectedPeriod == period ? "checkmark" : ""
                                )
                            }
                        }
                        
                        Divider()
                        
                        // 전체 삭제
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("전체 삭제", systemImage: "trash")
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "검색")
            .sheet(item: $selectedItem) { item in
                ScanResultView(message: item.message)
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView()
            }
            .alert("히스토리 삭제", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    historyManager.clearHistory()
                }
            } message: {
                Text("모든 스캔 히스토리를 삭제하시겠습니까?")
            }
        }
    }
    
    // MARK: - 필터링된 항목
    
    private var filteredItems: [ScanHistoryItem] {
        var items = historyManager.items(within: selectedPeriod)
        
        // 즐겨찾기 필터
        if showFavoritesOnly {
            items = items.filter { $0.isFavorite }
        }
        
        // 검색 필터
        if !searchText.isEmpty {
            items = items.filter { item in
                item.message.summary.localizedCaseInsensitiveContains(searchText) ||
                item.note?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        return items
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("스캔 히스토리가 없습니다")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("NFC 태그를 스캔하면\n여기에 기록됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 히스토리 리스트
    
    private var historyList: some View {
        List {
            // 필터 상태 표시
            if showFavoritesOnly || selectedPeriod != .all {
                filterStatusRow
            }
            
            // 히스토리 항목
            ForEach(filteredItems) { item in
                HistoryItemRow(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedItem = item
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            historyManager.toggleFavorite(item)
                        } label: {
                            Label(
                                item.isFavorite ? "즐겨찾기 해제" : "즐겨찾기",
                                systemImage: item.isFavorite ? "star.slash" : "star.fill"
                            )
                        }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            historyManager.deleteItem(item)
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - 필터 상태 행
    
    private var filterStatusRow: some View {
        HStack {
            if showFavoritesOnly {
                Label("즐겨찾기", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if selectedPeriod != .all {
                Label(selectedPeriod.rawValue, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.nfcPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.nfcPrimary.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Text("\(filteredItems.count)개")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 히스토리 항목 행

/// 히스토리 목록의 개별 항목
struct HistoryItemRow: View {
    let item: ScanHistoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 콘텐츠 타입 아이콘
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.nfcPrimary.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: item.message.primaryContentType.iconName)
                    .font(.title3)
                    .foregroundColor(.nfcPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // 요약
                Text(item.message.summary)
                    .font(.body)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // 태그 타입
                    Text(item.message.tagType.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                    
                    // 스캔 시간
                    Text(item.relativeDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 메모 (있는 경우)
                if let note = item.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 즐겨찾기 표시
            if item.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 통계 뷰

/// 스캔 통계를 표시하는 시트
struct StatisticsView: View {
    @EnvironmentObject var historyManager: ScanHistoryManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 개요 카드
                    overviewCard
                    
                    // 콘텐츠 타입별 통계
                    contentTypeCard
                    
                    // 태그 통계
                    tagStatsCard
                }
                .padding()
            }
            .background(Color.nfcBackground)
            .navigationTitle("통계")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var stats: ScanHistoryManager.Statistics {
        historyManager.statistics
    }
    
    // MARK: - 개요 카드
    
    private var overviewCard: some View {
        VStack(spacing: 16) {
            // 총 스캔 수
            VStack(spacing: 4) {
                Text("\(stats.totalScans)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.nfcPrimary)
                
                Text("총 스캔 횟수")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // 최근 스캔
            if let recentDate = stats.mostRecentScan {
                HStack {
                    Text("마지막 스캔")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatDate(recentDate))
                }
                .font(.subheadline)
            }
        }
        .cardStyle()
    }
    
    // MARK: - 콘텐츠 타입 카드
    
    private var contentTypeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("콘텐츠 타입별")
                .font(.headline)
            
            VStack(spacing: 12) {
                StatBar(
                    icon: "globe",
                    title: "URL",
                    count: stats.urlScans,
                    total: stats.totalScans,
                    color: .blue
                )
                
                StatBar(
                    icon: "text.alignleft",
                    title: "텍스트",
                    count: stats.textScans,
                    total: stats.totalScans,
                    color: .green
                )
                
                StatBar(
                    icon: "person.crop.circle",
                    title: "연락처",
                    count: stats.contactScans,
                    total: stats.totalScans,
                    color: .purple
                )
            }
        }
        .cardStyle()
    }
    
    // MARK: - 태그 통계 카드
    
    private var tagStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("태그 통계")
                .font(.headline)
            
            HStack {
                StatBox(
                    icon: "tag",
                    title: "고유 태그",
                    value: "\(stats.uniqueTags)"
                )
                
                StatBox(
                    icon: "star.fill",
                    title: "즐겨찾기",
                    value: "\(stats.favoriteCount)"
                )
            }
        }
        .cardStyle()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 통계 바

/// 비율을 표시하는 막대 그래프
struct StatBar: View {
    let icon: String
    let title: String
    let count: Int
    let total: Int
    let color: Color
    
    private var ratio: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * ratio)
                }
            }
            .frame(height: 8)
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - 통계 박스

/// 통계 수치를 표시하는 박스
struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.nfcPrimary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - 프리뷰

#Preview {
    HistoryView()
        .environmentObject(ScanHistoryManager())
}
