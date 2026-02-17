import Foundation
import ShazamKit

// MARK: - ShazamLibraryError
/// Shazam 라이브러리 서비스 오류 타입

enum ShazamLibraryError: LocalizedError {
    case notAuthorized              // 권한 없음
    case syncFailed(Error)          // 동기화 실패
    case itemNotFound               // 항목 없음
    case deletionFailed(Error)      // 삭제 실패
    case networkUnavailable         // 네트워크 불가
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Shazam 라이브러리 접근 권한이 없습니다."
        case .syncFailed(let error):
            return "동기화 실패: \(error.localizedDescription)"
        case .itemNotFound:
            return "항목을 찾을 수 없습니다."
        case .deletionFailed(let error):
            return "삭제 실패: \(error.localizedDescription)"
        case .networkUnavailable:
            return "네트워크 연결을 확인해주세요."
        }
    }
}

// MARK: - ShazamLibraryItem
/// Shazam 라이브러리 항목 모델

struct ShazamLibraryItem: Identifiable, Hashable {
    let id: String              // Shazam ID
    let title: String           // 곡 제목
    let artist: String          // 아티스트
    let artworkURL: URL?        // 앨범 아트
    let appleMusicURL: URL?     // Apple Music URL
    let webURL: URL?            // 웹 URL
    let shazammedAt: Date       // Shazam한 시간
    let genres: [String]        // 장르
    
    /// SHMediaItem에서 변환
    init(from mediaItem: SHMediaItem, shazammedAt: Date = Date()) {
        self.id = mediaItem.shazamID ?? UUID().uuidString
        self.title = mediaItem.title ?? "알 수 없는 곡"
        self.artist = mediaItem.artist ?? "알 수 없는 아티스트"
        self.artworkURL = mediaItem.artworkURL
        self.appleMusicURL = mediaItem.appleMusicURL
        self.webURL = mediaItem.webURL
        self.shazammedAt = shazammedAt
        self.genres = mediaItem.genres
    }
    
    /// 미리보기용 초기화
    init(
        id: String,
        title: String,
        artist: String,
        artworkURL: URL? = nil,
        appleMusicURL: URL? = nil,
        webURL: URL? = nil,
        shazammedAt: Date = Date(),
        genres: [String] = []
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.appleMusicURL = appleMusicURL
        self.webURL = webURL
        self.shazammedAt = shazammedAt
        self.genres = genres
    }
}

// MARK: - SyncStatus
/// 동기화 상태

enum SyncStatus: Equatable {
    case idle              // 대기 중
    case syncing           // 동기화 중
    case completed         // 완료
    case error(String)     // 오류
    
    static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.syncing, .syncing), (.completed, .completed):
            return true
        case (.error(let l), .error(let r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - ShazamLibraryService
/// Shazam 라이브러리 동기화 서비스
/// 사용자의 Shazam 기록을 iCloud와 동기화

@MainActor
@Observable
final class ShazamLibraryService {
    // MARK: - 싱글톤
    static let shared = ShazamLibraryService()
    
    // MARK: - 상태
    /// 라이브러리 항목
    private(set) var items: [ShazamLibraryItem] = []
    
    /// 동기화 상태
    private(set) var syncStatus: SyncStatus = .idle
    
    /// 마지막 동기화 시간
    private(set) var lastSyncDate: Date?
    
    /// 라이브러리 총 항목 수
    var itemCount: Int { items.count }
    
    // MARK: - ShazamKit 라이브러리
    private var library: SHLibrary { .default }
    
    // MARK: - 설정
    /// 자동 동기화 활성화
    var autoSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "ShazamLibraryAutoSync") }
        set { UserDefaults.standard.set(newValue, forKey: "ShazamLibraryAutoSync") }
    }
    
    /// 동기화 간격 (초)
    var syncInterval: TimeInterval {
        get { UserDefaults.standard.double(forKey: "ShazamLibrarySyncInterval").nonZero ?? 3600 }
        set { UserDefaults.standard.set(newValue, forKey: "ShazamLibrarySyncInterval") }
    }
    
    // MARK: - 초기화
    private init() {
        // 로컬 캐시 로드
        loadLocalCache()
        
        // 자동 동기화 설정
        if autoSyncEnabled {
            Task {
                await sync()
            }
        }
    }
    
    // MARK: - 라이브러리 동기화
    /// Shazam 라이브러리 동기화
    func sync() async {
        syncStatus = .syncing
        
        do {
            // SHLibrary에서 항목 조회
            var fetchedItems: [ShazamLibraryItem] = []
            
            // 비동기 시퀀스로 라이브러리 항목 조회
            for await item in library.items {
                let libraryItem = ShazamLibraryItem(from: item)
                fetchedItems.append(libraryItem)
            }
            
            // 정렬 (최신순)
            items = fetchedItems.sorted { $0.shazammedAt > $1.shazammedAt }
            
            // 로컬 캐시 저장
            saveLocalCache()
            
            lastSyncDate = Date()
            syncStatus = .completed
            
        } catch {
            syncStatus = .error(error.localizedDescription)
        }
    }
    
    // MARK: - 항목 추가
    /// 곡을 Shazam 라이브러리에 추가
    /// - Parameter mediaItem: SHMediaItem
    func addToLibrary(_ mediaItem: SHMediaItem) async throws {
        do {
            try await library.addItems([mediaItem])
            
            // 로컬 목록에도 추가
            let newItem = ShazamLibraryItem(from: mediaItem)
            items.insert(newItem, at: 0)
            
            saveLocalCache()
        } catch {
            throw ShazamLibraryError.syncFailed(error)
        }
    }
    
    /// MatchedSongModel에서 라이브러리에 추가
    func addToLibrary(from song: MatchedSongModel) async throws {
        // SHMediaItem 생성
        var properties: [SHMediaItemProperty: Any] = [
            .title: song.title,
            .artist: song.artist
        ]
        
        if let shazamID = song.shazamID {
            properties[.shazamID] = shazamID
        }
        
        if let artworkURL = song.artworkURL {
            properties[.artworkURL] = artworkURL
        }
        
        if let appleMusicURL = song.appleMusicURL {
            properties[.appleMusicURL] = appleMusicURL
        }
        
        if !song.genres.isEmpty {
            properties[.genres] = song.genres
        }
        
        let mediaItem = SHMediaItem(properties: properties)
        try await addToLibrary(mediaItem)
    }
    
    // MARK: - 항목 삭제
    /// 항목 삭제 (로컬에서만)
    func removeFromLocalList(_ item: ShazamLibraryItem) {
        items.removeAll { $0.id == item.id }
        saveLocalCache()
    }
    
    /// 여러 항목 삭제
    func removeFromLocalList(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveLocalCache()
    }
    
    // MARK: - 검색
    /// 라이브러리에서 검색
    func search(query: String) -> [ShazamLibraryItem] {
        guard !query.isEmpty else { return items }
        
        let lowercasedQuery = query.lowercased()
        return items.filter { item in
            item.title.lowercased().contains(lowercasedQuery) ||
            item.artist.lowercased().contains(lowercasedQuery) ||
            item.genres.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    /// 장르별 필터링
    func filterByGenre(_ genre: String) -> [ShazamLibraryItem] {
        items.filter { $0.genres.contains(genre) }
    }
    
    /// 기간별 필터링
    func filterByDateRange(from startDate: Date, to endDate: Date) -> [ShazamLibraryItem] {
        items.filter { item in
            item.shazammedAt >= startDate && item.shazammedAt <= endDate
        }
    }
    
    // MARK: - 통계
    /// 장르별 통계
    var genreStatistics: [(genre: String, count: Int)] {
        var genreCounts: [String: Int] = [:]
        
        for item in items {
            for genre in item.genres {
                genreCounts[genre, default: 0] += 1
            }
        }
        
        return genreCounts
            .map { (genre: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    /// 아티스트별 통계
    var artistStatistics: [(artist: String, count: Int)] {
        var artistCounts: [String: Int] = [:]
        
        for item in items {
            artistCounts[item.artist, default: 0] += 1
        }
        
        return artistCounts
            .map { (artist: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    /// 기간별 통계 (일별)
    var dailyStatistics: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        var dayCounts: [Date: Int] = [:]
        
        for item in items {
            let dayStart = calendar.startOfDay(for: item.shazammedAt)
            dayCounts[dayStart, default: 0] += 1
        }
        
        return dayCounts
            .map { (date: $0.key, count: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - 내보내기
    /// 라이브러리를 JSON으로 내보내기
    func exportToJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let exportData = items.map { item in
            [
                "id": item.id,
                "title": item.title,
                "artist": item.artist,
                "shazammedAt": ISO8601DateFormatter().string(from: item.shazammedAt),
                "genres": item.genres
            ] as [String: Any]
        }
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    /// CSV로 내보내기
    func exportToCSV() -> String {
        var csv = "제목,아티스트,장르,Shazam 날짜\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for item in items {
            let genres = item.genres.joined(separator: "; ")
            let date = dateFormatter.string(from: item.shazammedAt)
            csv += "\"\(item.title)\",\"\(item.artist)\",\"\(genres)\",\"\(date)\"\n"
        }
        
        return csv
    }
    
    // MARK: - 로컬 캐시
    private var cacheFileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("ShazamLibraryCache.json")
    }
    
    /// 로컬 캐시 저장
    private func saveLocalCache() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(items.map { CachedItem(from: $0) })
            try data.write(to: cacheFileURL)
        } catch {
            print("⚠️ 캐시 저장 실패: \(error.localizedDescription)")
        }
    }
    
    /// 로컬 캐시 로드
    private func loadLocalCache() {
        guard FileManager.default.fileExists(atPath: cacheFileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: cacheFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let cachedItems = try decoder.decode([CachedItem].self, from: data)
            items = cachedItems.map { $0.toLibraryItem() }
        } catch {
            print("⚠️ 캐시 로드 실패: \(error.localizedDescription)")
        }
    }
    
    /// 캐시 삭제
    func clearCache() {
        try? FileManager.default.removeItem(at: cacheFileURL)
        items = []
    }
}

// MARK: - 캐시용 Codable 구조체
private struct CachedItem: Codable {
    let id: String
    let title: String
    let artist: String
    let artworkURLString: String?
    let appleMusicURLString: String?
    let webURLString: String?
    let shazammedAt: Date
    let genres: [String]
    
    init(from item: ShazamLibraryItem) {
        self.id = item.id
        self.title = item.title
        self.artist = item.artist
        self.artworkURLString = item.artworkURL?.absoluteString
        self.appleMusicURLString = item.appleMusicURL?.absoluteString
        self.webURLString = item.webURL?.absoluteString
        self.shazammedAt = item.shazammedAt
        self.genres = item.genres
    }
    
    func toLibraryItem() -> ShazamLibraryItem {
        ShazamLibraryItem(
            id: id,
            title: title,
            artist: artist,
            artworkURL: artworkURLString.flatMap { URL(string: $0) },
            appleMusicURL: appleMusicURLString.flatMap { URL(string: $0) },
            webURL: webURLString.flatMap { URL(string: $0) },
            shazammedAt: shazammedAt,
            genres: genres
        )
    }
}

// MARK: - 헬퍼 확장
private extension Double {
    var nonZero: Double? {
        self != 0 ? self : nil
    }
}

// MARK: - 미리보기 데이터
extension ShazamLibraryItem {
    static var preview: ShazamLibraryItem {
        ShazamLibraryItem(
            id: "preview-1",
            title: "Blinding Lights",
            artist: "The Weeknd",
            genres: ["Pop", "Synth-pop"],
            shazammedAt: Date()
        )
    }
    
    static var previewList: [ShazamLibraryItem] {
        [
            ShazamLibraryItem(
                id: "1",
                title: "Blinding Lights",
                artist: "The Weeknd",
                genres: ["Pop"],
                shazammedAt: Date()
            ),
            ShazamLibraryItem(
                id: "2",
                title: "Shape of You",
                artist: "Ed Sheeran",
                genres: ["Pop"],
                shazammedAt: Date().addingTimeInterval(-3600)
            ),
            ShazamLibraryItem(
                id: "3",
                title: "Dynamite",
                artist: "BTS",
                genres: ["K-Pop", "Dance"],
                shazammedAt: Date().addingTimeInterval(-86400)
            )
        ]
    }
}
