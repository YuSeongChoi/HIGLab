import SwiftUI
import SwiftData

// MARK: - HistoryView
/// 인식 기록을 표시하는 뷰
/// SwiftData 기반 HistoryStore 활용

struct HistoryView: View {
    // MARK: - 환경
    @Environment(HistoryStore.self) private var store
    
    // MARK: - 상태
    @State private var searchText = ""
    @State private var selectedFilter: HistoryFilter = .all
    @State private var groupedSongs: [(date: Date, songs: [MatchedSongModel])] = []
    @State private var isLoading = true
    @State private var showingStatistics = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if groupedSongs.isEmpty && searchText.isEmpty {
                emptyView
            } else if groupedSongs.isEmpty {
                noResultsView
            } else {
                songListView
            }
        }
        .searchable(text: $searchText, prompt: "곡 또는 아티스트 검색")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // 필터 메뉴
                Menu {
                    Picker("필터", selection: $selectedFilter) {
                        ForEach(HistoryFilter.allCases) { filter in
                            Label(filter.title, systemImage: filter.icon)
                                .tag(filter)
                        }
                    }
                } label: {
                    Image(systemName: selectedFilter.icon)
                }
                
                // 통계 버튼
                Button {
                    showingStatistics = true
                } label: {
                    Image(systemName: "chart.bar.fill")
                }
                
                // 삭제 메뉴
                Menu {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("전체 삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await loadData()
        }
        .onChange(of: searchText) {
            Task { await loadData() }
        }
        .onChange(of: selectedFilter) {
            Task { await loadData() }
        }
        .refreshable {
            await loadData()
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView()
        }
        .alert("전체 삭제", isPresented: $showingDeleteConfirmation) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                store.deleteAll()
                Task { await loadData() }
            }
        } message: {
            Text("모든 인식 기록이 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
        }
    }
    
    // MARK: - 로딩 뷰
    private var loadingView: some View {
        ProgressView("불러오는 중...")
    }
    
    // MARK: - 빈 상태 뷰
    private var emptyView: some View {
        ContentUnavailableView(
            "인식 기록이 없습니다",
            systemImage: "clock.badge.questionmark",
            description: Text("음악을 인식하면 여기에 기록됩니다")
        )
    }
    
    // MARK: - 검색 결과 없음 뷰
    private var noResultsView: some View {
        ContentUnavailableView.search(text: searchText)
    }
    
    // MARK: - 곡 목록 뷰
    private var songListView: some View {
        List {
            // 통계 요약 헤더
            Section {
                StatisticsSummaryRow(count: store.totalMatchCount)
            }
            
            // 날짜별 그룹
            ForEach(groupedSongs, id: \.date) { group in
                Section(HistoryStore.relativeDateString(for: group.date)) {
                    ForEach(group.songs) { song in
                        NavigationLink {
                            SongDetailView(song: song)
                        } label: {
                            SongRowView(song: song)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.delete(song)
                                Task { await loadData() }
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                store.toggleFavorite(song)
                            } label: {
                                Label(
                                    song.isFavorite ? "즐겨찾기 해제" : "즐겨찾기",
                                    systemImage: song.isFavorite ? "star.slash" : "star"
                                )
                            }
                            .tint(.yellow)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - 데이터 로드
    private func loadData() async {
        isLoading = true
        
        // 필터에 따른 데이터 조회
        var songs: [MatchedSongModel]
        
        switch selectedFilter {
        case .all:
            songs = searchText.isEmpty
                ? await store.fetchAll()
                : await store.search(query: searchText)
        case .favorites:
            songs = await store.fetchFavoriteSongs()
            if !searchText.isEmpty {
                songs = songs.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.artist.localizedCaseInsensitiveContains(searchText)
                }
            }
        case .recent:
            songs = await store.fetchRecentSongs(limit: 20)
            if !searchText.isEmpty {
                songs = songs.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.artist.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        // 날짜별 그룹화
        groupedSongs = groupByDate(songs)
        
        isLoading = false
    }
    
    /// 날짜별 그룹화
    private func groupByDate(_ songs: [MatchedSongModel]) -> [(date: Date, songs: [MatchedSongModel])] {
        let calendar = Calendar.current
        var grouped: [Date: [MatchedSongModel]] = [:]
        
        for song in songs {
            let dayStart = calendar.startOfDay(for: song.matchedAt)
            grouped[dayStart, default: []].append(song)
        }
        
        return grouped
            .map { (date: $0.key, songs: $0.value) }
            .sorted { $0.date > $1.date }
    }
}

// MARK: - HistoryFilter
/// 기록 필터 옵션

enum HistoryFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case favorites = "favorites"
    case recent = "recent"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .all: return "전체"
        case .favorites: return "즐겨찾기"
        case .recent: return "최근"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .favorites: return "star.fill"
        case .recent: return "clock"
        }
    }
}

// MARK: - StatisticsSummaryRow
/// 통계 요약 행

struct StatisticsSummaryRow: View {
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: "music.note.list")
                .font(.title2)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("총 인식 횟수")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("\(count)곡")
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - SongRowView
/// 곡 목록 행

struct SongRowView: View {
    let song: MatchedSongModel
    @Environment(AppSettings.self) private var settings
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - 앨범 아트
            AsyncImage(url: song.artworkURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    artworkPlaceholder
                @unknown default:
                    artworkPlaceholder
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // MARK: - 곡 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(song.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if song.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                    
                    if song.isExplicitContent {
                        Image(systemName: "e.square.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // 장르 태그 (설정에 따라)
                if settings.showGenreTags && !song.genres.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(song.genres.prefix(2), id: \.self) { genre in
                            Text(genre)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Spacer()
            
            // MARK: - 시간 및 카운트
            VStack(alignment: .trailing, spacing: 4) {
                Text(HistoryStore.timeString(for: song.matchedAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                if song.playCount > 1 {
                    Text("\(song.playCount)회")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // 앨범 아트 플레이스홀더
    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.gray.opacity(0.2))
            .overlay {
                Image(systemName: "music.note")
                    .foregroundStyle(.gray)
            }
    }
}

// MARK: - StatisticsView
/// 통계 뷰

struct StatisticsView: View {
    @Environment(HistoryStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    @State private var genreStats: [(genre: String, count: Int)] = []
    @State private var artistStats: [(artist: String, count: Int)] = []
    @State private var periodStats: (last7Days: Int, last30Days: Int, total: Int) = (0, 0, 0)
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            List {
                // 기간별 통계
                Section("기간별") {
                    StatRow(title: "지난 7일", value: "\(periodStats.last7Days)곡")
                    StatRow(title: "지난 30일", value: "\(periodStats.last30Days)곡")
                    StatRow(title: "전체", value: "\(periodStats.total)곡")
                }
                
                // 장르별 통계
                if !genreStats.isEmpty {
                    Section("인기 장르") {
                        ForEach(genreStats.prefix(5), id: \.genre) { stat in
                            StatRow(title: stat.genre, value: "\(stat.count)곡")
                        }
                    }
                }
                
                // 아티스트별 통계
                if !artistStats.isEmpty {
                    Section("자주 듣는 아티스트") {
                        ForEach(artistStats.prefix(5), id: \.artist) { stat in
                            StatRow(title: stat.artist, value: "\(stat.count)곡")
                        }
                    }
                }
            }
            .navigationTitle("통계")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
            .task {
                await loadStatistics()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    private func loadStatistics() async {
        isLoading = true
        
        genreStats = await store.genreStatistics()
        artistStats = await store.artistStatistics()
        periodStats = await store.periodStatistics()
        
        isLoading = false
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("기록 있음") {
    NavigationStack {
        HistoryView()
            .navigationTitle("인식 기록")
    }
    .environment(HistoryStore.shared)
    .environment(AppSettings.shared)
}

#Preview("빈 상태") {
    NavigationStack {
        ContentUnavailableView(
            "인식 기록이 없습니다",
            systemImage: "clock.badge.questionmark",
            description: Text("음악을 인식하면 여기에 기록됩니다")
        )
    }
}
