import Foundation
import MusicKit

// MARK: - Music Service
// MusicKit API를 래핑한 서비스 클래스

@MainActor
class MusicService: ObservableObject {
    static let shared = MusicService()
    
    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
    
    private init() {}
    
    // MARK: - Authorization
    // 권한 요청
    
    func requestAuthorization() async -> MusicAuthorization.Status {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
        return status
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = MusicAuthorization.currentStatus
    }
    
    // MARK: - Search
    // Apple Music 카탈로그 검색
    
    /// 노래 검색
    func searchSongs(query: String, limit: Int = 25) async throws -> [SongItem] {
        guard !query.isEmpty else { return [] }
        
        var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
        request.limit = limit
        
        let response = try await request.response()
        return response.songs.map { SongItem(from: $0) }
    }
    
    /// 앨범 검색
    func searchAlbums(query: String, limit: Int = 25) async throws -> [AlbumItem] {
        guard !query.isEmpty else { return [] }
        
        var request = MusicCatalogSearchRequest(term: query, types: [Album.self])
        request.limit = limit
        
        let response = try await request.response()
        return response.albums.map { AlbumItem(from: $0) }
    }
    
    /// 아티스트 검색
    func searchArtists(query: String, limit: Int = 25) async throws -> [ArtistItem] {
        guard !query.isEmpty else { return [] }
        
        var request = MusicCatalogSearchRequest(term: query, types: [Artist.self])
        request.limit = limit
        
        let response = try await request.response()
        return response.artists.map { ArtistItem(from: $0) }
    }
    
    // MARK: - Library
    // 사용자 라이브러리 조회
    
    /// 라이브러리 곡 목록
    func fetchLibrarySongs(limit: Int = 50) async throws -> [SongItem] {
        var request = MusicLibraryRequest<Song>()
        request.limit = limit
        request.sort(by: \.dateAdded, ascending: false)
        
        let response = try await request.response()
        return response.items.map { SongItem(from: $0) }
    }
    
    /// 라이브러리 앨범 목록
    func fetchLibraryAlbums(limit: Int = 50) async throws -> [AlbumItem] {
        var request = MusicLibraryRequest<Album>()
        request.limit = limit
        request.sort(by: \.dateAdded, ascending: false)
        
        let response = try await request.response()
        return response.items.map { AlbumItem(from: $0) }
    }
    
    /// 최근 재생 항목
    func fetchRecentlyPlayed(limit: Int = 25) async throws -> [SongItem] {
        var request = MusicRecentlyPlayedRequest<Song>()
        request.limit = limit
        
        let response = try await request.response()
        return response.items.map { SongItem(from: $0) }
    }
    
    // MARK: - Charts
    // 차트/추천
    
    /// 인기 차트 곡
    func fetchTopCharts() async throws -> [SongItem] {
        let request = MusicCatalogChartsRequest(kinds: [.mostPlayed], types: [Song.self])
        let response = try await request.response()
        
        guard let chart = response.songCharts.first else { return [] }
        return chart.items.map { SongItem(from: $0) }
    }
}

// MARK: - Error Types

enum MusicServiceError: LocalizedError {
    case notAuthorized
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Apple Music 접근 권한이 필요합니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
