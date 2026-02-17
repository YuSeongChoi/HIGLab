import Foundation
import SwiftData
import ShazamKit

// MARK: - HistoryStore
/// SwiftData 기반 인식 기록 저장소
/// MatchedSongModel의 CRUD 및 쿼리 기능 제공

@MainActor
@Observable
final class HistoryStore {
    // MARK: - 싱글톤
    static let shared = HistoryStore()
    
    // MARK: - SwiftData 컨테이너
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    // MARK: - 캐시된 데이터
    private(set) var recentSongs: [MatchedSongModel] = []
    private(set) var favoriteSongs: [MatchedSongModel] = []
    
    /// 총 인식 횟수
    private(set) var totalMatchCount: Int = 0
    
    // MARK: - 초기화
    private init() {
        setupContainer()
        loadInitialData()
    }
    
    /// SwiftData 컨테이너 설정
    private func setupContainer() {
        do {
            let schema = Schema([MatchedSongModel.self])
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic  // iCloud 동기화 활성화
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            modelContext = modelContainer?.mainContext
        } catch {
            print("❌ SwiftData 컨테이너 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    /// 초기 데이터 로드
    private func loadInitialData() {
        Task {
            await refresh()
        }
    }
    
    // MARK: - 새로고침
    /// 모든 데이터 새로고침
    func refresh() async {
        recentSongs = await fetchRecentSongs(limit: 50)
        favoriteSongs = await fetchFavoriteSongs()
        totalMatchCount = await fetchTotalCount()
    }
    
    // MARK: - 곡 추가
    /// 새 곡 추가
    @discardableResult
    func add(_ song: MatchedSongModel) -> Bool {
        guard let context = modelContext else { return false }
        
        // 중복 체크 (같은 Shazam ID)
        if let shazamID = song.shazamID, !shazamID.isEmpty {
            if let existing = findByShazamID(shazamID) {
                // 기존 곡 업데이트 (인식 횟수 증가)
                existing.matchedAt = Date()
                existing.playCount += 1
                save()
                
                Task { await refresh() }
                return true
            }
        }
        
        // 새로 추가
        context.insert(song)
        save()
        
        Task { await refresh() }
        return true
    }
    
    /// SHMatchedMediaItem에서 곡 추가
    @discardableResult
    func add(from matchedItem: SHMatchedMediaItem) -> MatchedSongModel {
        let song = MatchedSongModel(from: matchedItem, matchedMediaItem: matchedItem)
        add(song)
        return song
    }
    
    /// SHMediaItem에서 곡 추가
    @discardableResult
    func add(from mediaItem: SHMediaItem) -> MatchedSongModel {
        let song = MatchedSongModel(from: mediaItem)
        add(song)
        return song
    }
    
    // MARK: - 곡 조회
    /// Shazam ID로 곡 찾기
    func findByShazamID(_ shazamID: String) -> MatchedSongModel? {
        guard let context = modelContext else { return nil }
        
        let predicate = #Predicate<MatchedSongModel> { song in
            song.shazamID == shazamID
        }
        
        let descriptor = FetchDescriptor<MatchedSongModel>(predicate: predicate)
        
        return try? context.fetch(descriptor).first
    }
    
    /// ID로 곡 찾기
    func findByID(_ id: UUID) -> MatchedSongModel? {
        guard let context = modelContext else { return nil }
        
        let predicate = #Predicate<MatchedSongModel> { song in
            song.id == id
        }
        
        let descriptor = FetchDescriptor<MatchedSongModel>(predicate: predicate)
        
        return try? context.fetch(descriptor).first
    }
    
    /// 최근 곡 조회
    func fetchRecentSongs(limit: Int = 20) async -> [MatchedSongModel] {
        guard let context = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<MatchedSongModel>(
            sortBy: [SortDescriptor(\.matchedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// 즐겨찾기 곡 조회
    func fetchFavoriteSongs() async -> [MatchedSongModel] {
        guard let context = modelContext else { return [] }
        
        let predicate = #Predicate<MatchedSongModel> { song in
            song.isFavorite == true
        }
        
        var descriptor = FetchDescriptor<MatchedSongModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.matchedAt, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// 총 개수 조회
    func fetchTotalCount() async -> Int {
        guard let context = modelContext else { return 0 }
        
        let descriptor = FetchDescriptor<MatchedSongModel>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    /// 모든 곡 조회
    func fetchAll() async -> [MatchedSongModel] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<MatchedSongModel>(
            sortBy: [SortDescriptor(\.matchedAt, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - 곡 업데이트
    /// 즐겨찾기 토글
    func toggleFavorite(_ song: MatchedSongModel) {
        song.isFavorite.toggle()
        save()
        
        Task { await refresh() }
    }
    
    /// 메모 업데이트
    func updateNote(_ song: MatchedSongModel, note: String?) {
        song.userNote = note
        save()
    }
    
    /// Shazam Library에 추가됨 표시
    func markAsAddedToShazamLibrary(_ song: MatchedSongModel) {
        song.isAddedToShazamLibrary = true
        save()
    }
    
    /// 재생 카운트 증가
    func incrementPlayCount(_ song: MatchedSongModel) {
        song.playCount += 1
        song.lastPlayedAt = Date()
        save()
    }
    
    // MARK: - 곡 삭제
    /// 곡 삭제
    func delete(_ song: MatchedSongModel) {
        guard let context = modelContext else { return }
        
        context.delete(song)
        save()
        
        Task { await refresh() }
    }
    
    /// 여러 곡 삭제
    func delete(_ songs: [MatchedSongModel]) {
        guard let context = modelContext else { return }
        
        for song in songs {
            context.delete(song)
        }
        save()
        
        Task { await refresh() }
    }
    
    /// 모든 기록 삭제
    func deleteAll() {
        guard let context = modelContext else { return }
        
        do {
            try context.delete(model: MatchedSongModel.self)
            save()
            
            recentSongs = []
            favoriteSongs = []
            totalMatchCount = 0
        } catch {
            print("❌ 전체 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 검색
    /// 검색
    func search(query: String) async -> [MatchedSongModel] {
        guard let context = modelContext, !query.isEmpty else {
            return await fetchAll()
        }
        
        let lowercasedQuery = query.lowercased()
        
        // SwiftData의 Predicate는 복잡한 문자열 연산을 지원하지 않으므로
        // 메모리에서 필터링
        let allSongs = await fetchAll()
        
        return allSongs.filter { song in
            song.title.lowercased().contains(lowercasedQuery) ||
            song.artist.lowercased().contains(lowercasedQuery) ||
            song.genres.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    // MARK: - 날짜별 그룹화
    /// 날짜별 그룹화된 곡 목록
    func fetchGroupedByDate() async -> [(date: Date, songs: [MatchedSongModel])] {
        let allSongs = await fetchAll()
        let calendar = Calendar.current
        
        var grouped: [Date: [MatchedSongModel]] = [:]
        
        for song in allSongs {
            let dayStart = calendar.startOfDay(for: song.matchedAt)
            grouped[dayStart, default: []].append(song)
        }
        
        return grouped
            .map { (date: $0.key, songs: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - 통계
    /// 장르별 통계
    func genreStatistics() async -> [(genre: String, count: Int)] {
        let allSongs = await fetchAll()
        var genreCounts: [String: Int] = [:]
        
        for song in allSongs {
            for genre in song.genres {
                genreCounts[genre, default: 0] += 1
            }
        }
        
        return genreCounts
            .map { (genre: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    /// 아티스트별 통계
    func artistStatistics() async -> [(artist: String, count: Int)] {
        let allSongs = await fetchAll()
        var artistCounts: [String: Int] = [:]
        
        for song in allSongs {
            artistCounts[song.artist, default: 0] += 1
        }
        
        return artistCounts
            .map { (artist: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    /// 기간별 통계 (최근 7일, 30일, 전체)
    func periodStatistics() async -> (last7Days: Int, last30Days: Int, total: Int) {
        let allSongs = await fetchAll()
        let now = Date()
        let calendar = Calendar.current
        
        let last7Days = allSongs.filter {
            calendar.dateComponents([.day], from: $0.matchedAt, to: now).day ?? 0 <= 7
        }.count
        
        let last30Days = allSongs.filter {
            calendar.dateComponents([.day], from: $0.matchedAt, to: now).day ?? 0 <= 30
        }.count
        
        return (last7Days, last30Days, allSongs.count)
    }
    
    // MARK: - 내보내기
    /// JSON으로 내보내기
    func exportToJSON() async throws -> Data {
        let allSongs = await fetchAll()
        
        let exportData = allSongs.map { song in
            [
                "id": song.id.uuidString,
                "title": song.title,
                "artist": song.artist,
                "shazamID": song.shazamID ?? "",
                "genres": song.genres,
                "matchedAt": ISO8601DateFormatter().string(from: song.matchedAt),
                "isFavorite": song.isFavorite,
                "playCount": song.playCount
            ] as [String: Any]
        }
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    // MARK: - 저장
    /// 변경사항 저장
    private func save() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 컨테이너 접근
    /// SwiftData 컨테이너 (뷰에서 사용)
    var container: ModelContainer? {
        modelContainer
    }
}

// MARK: - 날짜 포맷팅 헬퍼
extension HistoryStore {
    /// 날짜를 상대적 문자열로 변환
    static func relativeDateString(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "오늘"
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M월 d일 (E)"
            return formatter.string(from: date)
        }
    }
    
    /// 시간 포맷팅
    static func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
