import Foundation
import MusicKit
import ShazamKit

// MARK: - MusicKitServiceError
/// MusicKit 서비스 오류 타입

enum MusicKitServiceError: LocalizedError {
    case authorizationDenied           // 권한 거부
    case authorizationRestricted       // 권한 제한
    case songNotFound                  // 곡 찾기 실패
    case lyricsNotAvailable            // 가사 없음
    case playbackFailed(Error)         // 재생 실패
    case searchFailed(Error)           // 검색 실패
    case networkError                  // 네트워크 오류
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Apple Music 접근 권한이 거부되었습니다."
        case .authorizationRestricted:
            return "Apple Music 접근이 제한되어 있습니다."
        case .songNotFound:
            return "Apple Music에서 곡을 찾을 수 없습니다."
        case .lyricsNotAvailable:
            return "이 곡의 가사를 사용할 수 없습니다."
        case .playbackFailed(let error):
            return "재생 실패: \(error.localizedDescription)"
        case .searchFailed(let error):
            return "검색 실패: \(error.localizedDescription)"
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        }
    }
}

// MARK: - MusicKitAuthorizationStatus
/// MusicKit 권한 상태

enum MusicKitAuthorizationStatus {
    case authorized        // 허용됨
    case denied            // 거부됨
    case restricted        // 제한됨
    case notDetermined     // 미결정
    
    init(from status: MusicAuthorization.Status) {
        switch status {
        case .authorized:
            self = .authorized
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        case .notDetermined:
            self = .notDetermined
        @unknown default:
            self = .notDetermined
        }
    }
}

// MARK: - AppleMusicSong
/// Apple Music 곡 정보 모델

struct AppleMusicSong: Identifiable, Hashable {
    let id: String
    let title: String
    let artistName: String
    let albumTitle: String?
    let artworkURL: URL?
    let duration: TimeInterval
    let releaseDate: Date?
    let genreNames: [String]
    let isExplicit: Bool
    let hasLyrics: Bool
    let previewURL: URL?
    let appleMusicURL: URL?
    
    /// MusicKit Song에서 변환
    init(from song: Song) {
        self.id = song.id.rawValue
        self.title = song.title
        self.artistName = song.artistName
        self.albumTitle = song.albumTitle
        self.artworkURL = song.artwork?.url(width: 500, height: 500)
        self.duration = song.duration ?? 0
        self.releaseDate = song.releaseDate
        self.genreNames = song.genreNames
        self.isExplicit = song.contentRating == .explicit
        self.hasLyrics = song.hasLyrics
        self.previewURL = song.previewAssets?.first?.url
        self.appleMusicURL = song.url
    }
}

// MARK: - LyricLine
/// 가사 라인

struct LyricLine: Identifiable, Hashable {
    let id = UUID()
    let text: String           // 가사 텍스트
    let startTime: TimeInterval // 시작 시간
    let endTime: TimeInterval   // 종료 시간
    let isMainVocal: Bool       // 메인 보컬 여부
}

// MARK: - SongLyrics
/// 곡 가사 전체

struct SongLyrics: Identifiable {
    let id = UUID()
    let songId: String
    let songTitle: String
    let artistName: String
    let lines: [LyricLine]
    let language: String?
    let hasSyncedLyrics: Bool  // 싱크 가사 여부
    
    /// 특정 시간의 가사 라인 찾기
    func lineAt(time: TimeInterval) -> LyricLine? {
        return lines.first { line in
            time >= line.startTime && time < line.endTime
        }
    }
    
    /// 전체 가사 텍스트
    var fullText: String {
        lines.map { $0.text }.joined(separator: "\n")
    }
}

// MARK: - MusicKitService
/// Apple Music/MusicKit 연동 서비스
/// 곡 검색, 재생, 가사 조회 기능 제공

@MainActor
@Observable
final class MusicKitService {
    // MARK: - 싱글톤
    static let shared = MusicKitService()
    
    // MARK: - 상태
    /// 권한 상태
    private(set) var authorizationStatus: MusicKitAuthorizationStatus = .notDetermined
    
    /// 현재 재생 중인 곡
    private(set) var nowPlaying: AppleMusicSong?
    
    /// 재생 상태
    private(set) var isPlaying: Bool = false
    
    /// 현재 재생 시간
    private(set) var currentPlaybackTime: TimeInterval = 0
    
    // MARK: - 뮤직 플레이어
    private let player = ApplicationMusicPlayer.shared
    
    // MARK: - 초기화
    private init() {
        updateAuthorizationStatus()
    }
    
    // MARK: - 권한 관리
    /// 현재 권한 상태 업데이트
    func updateAuthorizationStatus() {
        let status = MusicAuthorization.currentStatus
        authorizationStatus = MusicKitAuthorizationStatus(from: status)
    }
    
    /// 권한 요청
    func requestAuthorization() async -> MusicKitAuthorizationStatus {
        let status = await MusicAuthorization.request()
        authorizationStatus = MusicKitAuthorizationStatus(from: status)
        return authorizationStatus
    }
    
    /// 권한 확인 및 요청
    func ensureAuthorized() async throws {
        if authorizationStatus != .authorized {
            let newStatus = await requestAuthorization()
            
            switch newStatus {
            case .denied:
                throw MusicKitServiceError.authorizationDenied
            case .restricted:
                throw MusicKitServiceError.authorizationRestricted
            case .notDetermined:
                throw MusicKitServiceError.authorizationDenied
            case .authorized:
                break
            }
        }
    }
    
    // MARK: - 곡 검색
    /// Shazam 인식 결과에서 Apple Music 곡 검색
    /// - Parameter matchedItem: SHMatchedMediaItem
    /// - Returns: Apple Music 곡 정보
    func searchSong(from matchedItem: SHMatchedMediaItem) async throws -> AppleMusicSong? {
        try await ensureAuthorized()
        
        // ISRC로 검색 (가장 정확)
        if let isrc = matchedItem.isrc {
            if let song = try await searchByISRC(isrc) {
                return song
            }
        }
        
        // Apple Music URL로 검색
        if let appleMusicURL = matchedItem.appleMusicURL {
            if let song = try await searchByURL(appleMusicURL) {
                return song
            }
        }
        
        // 제목과 아티스트로 검색
        if let title = matchedItem.title, let artist = matchedItem.artist {
            return try await searchByTitleAndArtist(title: title, artist: artist)
        }
        
        return nil
    }
    
    /// 제목과 아티스트로 검색
    func searchByTitleAndArtist(title: String, artist: String) async throws -> AppleMusicSong? {
        try await ensureAuthorized()
        
        do {
            var request = MusicCatalogSearchRequest(term: "\(title) \(artist)", types: [Song.self])
            request.limit = 5
            
            let response = try await request.response()
            
            // 가장 일치하는 곡 찾기
            let song = response.songs.first { song in
                song.title.localizedCaseInsensitiveContains(title) &&
                song.artistName.localizedCaseInsensitiveContains(artist)
            } ?? response.songs.first
            
            return song.map { AppleMusicSong(from: $0) }
        } catch {
            throw MusicKitServiceError.searchFailed(error)
        }
    }
    
    /// ISRC로 검색
    func searchByISRC(_ isrc: String) async throws -> AppleMusicSong? {
        try await ensureAuthorized()
        
        do {
            var request = MusicCatalogSearchRequest(term: isrc, types: [Song.self])
            request.limit = 1
            
            let response = try await request.response()
            return response.songs.first.map { AppleMusicSong(from: $0) }
        } catch {
            return nil
        }
    }
    
    /// Apple Music URL로 검색
    func searchByURL(_ url: URL) async throws -> AppleMusicSong? {
        try await ensureAuthorized()
        
        // URL에서 ID 추출
        let pathComponents = url.pathComponents
        guard let idIndex = pathComponents.firstIndex(of: "album")?.advanced(by: 2),
              idIndex < pathComponents.count else {
            return nil
        }
        
        // ID 기반 검색
        let songId = pathComponents[idIndex]
        
        do {
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(songId))
            let response = try await request.response()
            return response.items.first.map { AppleMusicSong(from: $0) }
        } catch {
            return nil
        }
    }
    
    /// 일반 검색
    func search(query: String, limit: Int = 20) async throws -> [AppleMusicSong] {
        try await ensureAuthorized()
        
        do {
            var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
            request.limit = limit
            
            let response = try await request.response()
            return response.songs.map { AppleMusicSong(from: $0) }
        } catch {
            throw MusicKitServiceError.searchFailed(error)
        }
    }
    
    // MARK: - 가사 조회
    /// 곡의 가사 조회
    /// - Parameter songId: Apple Music 곡 ID
    /// - Returns: 가사 정보 (nil이면 가사 없음)
    func fetchLyrics(for songId: String) async throws -> SongLyrics? {
        try await ensureAuthorized()
        
        do {
            // 곡 상세 정보 조회 (가사 포함)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(songId))
            let response = try await request.response()
            
            guard let song = response.items.first else {
                throw MusicKitServiceError.songNotFound
            }
            
            // 가사 사용 가능 여부 확인
            guard song.hasLyrics else {
                throw MusicKitServiceError.lyricsNotAvailable
            }
            
            // 가사 조회 (MusicKit의 가사 API 사용)
            // 참고: 실제 가사 API는 제한적이므로 기본 정보만 반환
            return SongLyrics(
                songId: songId,
                songTitle: song.title,
                artistName: song.artistName,
                lines: [], // 실제 가사 라인은 별도 API 필요
                language: nil,
                hasSyncedLyrics: false
            )
        } catch let error as MusicKitServiceError {
            throw error
        } catch {
            throw MusicKitServiceError.searchFailed(error)
        }
    }
    
    // MARK: - 재생 제어
    /// 곡 재생
    func play(song: AppleMusicSong) async throws {
        try await ensureAuthorized()
        
        do {
            // Apple Music에서 곡 조회
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(song.id))
            let response = try await request.response()
            
            guard let musicKitSong = response.items.first else {
                throw MusicKitServiceError.songNotFound
            }
            
            // 플레이어 큐 설정
            player.queue = [musicKitSong]
            
            // 재생
            try await player.play()
            
            nowPlaying = song
            isPlaying = true
        } catch let error as MusicKitServiceError {
            throw error
        } catch {
            throw MusicKitServiceError.playbackFailed(error)
        }
    }
    
    /// 재생 일시정지
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    /// 재생 재개
    func resume() async throws {
        do {
            try await player.play()
            isPlaying = true
        } catch {
            throw MusicKitServiceError.playbackFailed(error)
        }
    }
    
    /// 재생 중지
    func stop() {
        player.stop()
        isPlaying = false
        nowPlaying = nil
        currentPlaybackTime = 0
    }
    
    /// 특정 시간으로 이동
    func seek(to time: TimeInterval) {
        player.playbackTime = time
        currentPlaybackTime = time
    }
    
    // MARK: - 미리 듣기
    /// 미리 듣기 URL로 재생 (Apple Music 구독 불필요)
    func playPreview(url: URL) async throws {
        // 미리 듣기는 AVPlayer 사용
        // 실제 구현은 AVFoundation 사용 필요
    }
    
    // MARK: - 라이브러리 관리
    /// 곡을 라이브러리에 추가
    func addToLibrary(song: AppleMusicSong) async throws {
        try await ensureAuthorized()
        
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(song.id))
        let response = try await request.response()
        
        guard let musicKitSong = response.items.first else {
            throw MusicKitServiceError.songNotFound
        }
        
        try await MusicLibrary.shared.add(musicKitSong)
    }
    
    /// 재생목록 생성
    func createPlaylist(name: String, songs: [AppleMusicSong]) async throws {
        try await ensureAuthorized()
        
        // 곡 ID 목록으로 MusicKit Song 조회
        var musicKitSongs: [Song] = []
        
        for appleMusicSong in songs {
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(appleMusicSong.id))
            if let response = try? await request.response(),
               let song = response.items.first {
                musicKitSongs.append(song)
            }
        }
        
        // 재생목록 생성
        try await MusicLibrary.shared.createPlaylist(name: name, items: musicKitSongs)
    }
}

// MARK: - 미리보기 데이터
extension AppleMusicSong {
    static var preview: AppleMusicSong {
        AppleMusicSong(
            id: "preview-1",
            title: "Blinding Lights",
            artistName: "The Weeknd",
            albumTitle: "After Hours",
            artworkURL: nil,
            duration: 200,
            releaseDate: Date(),
            genreNames: ["Pop", "Synth-pop"],
            isExplicit: false,
            hasLyrics: true,
            previewURL: nil,
            appleMusicURL: nil
        )
    }
    
    // 직접 초기화 (미리보기용)
    init(
        id: String,
        title: String,
        artistName: String,
        albumTitle: String?,
        artworkURL: URL?,
        duration: TimeInterval,
        releaseDate: Date?,
        genreNames: [String],
        isExplicit: Bool,
        hasLyrics: Bool,
        previewURL: URL?,
        appleMusicURL: URL?
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.albumTitle = albumTitle
        self.artworkURL = artworkURL
        self.duration = duration
        self.releaseDate = releaseDate
        self.genreNames = genreNames
        self.isExplicit = isExplicit
        self.hasLyrics = hasLyrics
        self.previewURL = previewURL
        self.appleMusicURL = appleMusicURL
    }
}

extension SongLyrics {
    static var preview: SongLyrics {
        SongLyrics(
            songId: "preview-1",
            songTitle: "Blinding Lights",
            artistName: "The Weeknd",
            lines: [
                LyricLine(text: "I've been tryna call", startTime: 0, endTime: 3, isMainVocal: true),
                LyricLine(text: "I've been on my own for long enough", startTime: 3, endTime: 6, isMainVocal: true),
                LyricLine(text: "Maybe you can show me how to love, maybe", startTime: 6, endTime: 10, isMainVocal: true)
            ],
            language: "en",
            hasSyncedLyrics: true
        )
    }
}
