import Foundation
import MusicKit

// MARK: - Music Item Wrappers
// MusicKit의 Song, Album, Artist를 UI에서 쉽게 사용하기 위한 래퍼

/// 곡 정보 래퍼
struct SongItem: Identifiable, Hashable {
    let id: MusicItemID
    let title: String
    let artistName: String
    let albumTitle: String?
    let artwork: Artwork?
    let duration: TimeInterval?
    
    // MusicKit Song에서 변환
    init(from song: Song) {
        self.id = song.id
        self.title = song.title
        self.artistName = song.artistName
        self.albumTitle = song.albumTitle
        self.artwork = song.artwork
        self.duration = song.duration
    }
    
    // Preview용 생성자
    init(
        id: MusicItemID = MusicItemID(rawValue: UUID().uuidString),
        title: String,
        artistName: String,
        albumTitle: String? = nil,
        artwork: Artwork? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.albumTitle = albumTitle
        self.artwork = artwork
        self.duration = duration
    }
    
    // 재생 시간 포맷팅 (3:45 형식)
    var formattedDuration: String {
        guard let duration = duration else { return "--:--" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// 앨범 정보 래퍼
struct AlbumItem: Identifiable, Hashable {
    let id: MusicItemID
    let title: String
    let artistName: String
    let artwork: Artwork?
    let releaseDate: Date?
    let trackCount: Int?
    
    init(from album: Album) {
        self.id = album.id
        self.title = album.title
        self.artistName = album.artistName
        self.artwork = album.artwork
        self.releaseDate = album.releaseDate
        self.trackCount = album.trackCount
    }
    
    init(
        id: MusicItemID = MusicItemID(rawValue: UUID().uuidString),
        title: String,
        artistName: String,
        artwork: Artwork? = nil,
        releaseDate: Date? = nil,
        trackCount: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.artwork = artwork
        self.releaseDate = releaseDate
        self.trackCount = trackCount
    }
    
    // 출시 연도
    var releaseYear: String? {
        guard let date = releaseDate else { return nil }
        return String(Calendar.current.component(.year, from: date))
    }
}

/// 아티스트 정보 래퍼
struct ArtistItem: Identifiable, Hashable {
    let id: MusicItemID
    let name: String
    let artwork: Artwork?
    
    init(from artist: Artist) {
        self.id = artist.id
        self.name = artist.name
        self.artwork = artist.artwork
    }
    
    init(
        id: MusicItemID = MusicItemID(rawValue: UUID().uuidString),
        name: String,
        artwork: Artwork? = nil
    ) {
        self.id = id
        self.name = name
        self.artwork = artwork
    }
}

// MARK: - Search Result Type
// 검색 결과 타입 구분

enum SearchResultType: String, CaseIterable, Identifiable {
    case songs = "노래"
    case albums = "앨범"
    case artists = "아티스트"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .songs: return "music.note"
        case .albums: return "square.stack"
        case .artists: return "person.fill"
        }
    }
}

// MARK: - Preview Data

extension SongItem {
    static let preview = SongItem(
        title: "Love Dive",
        artistName: "IVE",
        albumTitle: "Love Dive - Single",
        duration: 197
    )
    
    static let previewList: [SongItem] = [
        SongItem(title: "Love Dive", artistName: "IVE", albumTitle: "Love Dive - Single", duration: 197),
        SongItem(title: "Attention", artistName: "NewJeans", albumTitle: "NewJeans", duration: 181),
        SongItem(title: "Dynamite", artistName: "BTS", albumTitle: "Dynamite - Single", duration: 199),
        SongItem(title: "ANTIFRAGILE", artistName: "LE SSERAFIM", albumTitle: "ANTIFRAGILE", duration: 188),
        SongItem(title: "After LIKE", artistName: "IVE", albumTitle: "After LIKE - Single", duration: 178)
    ]
}

extension AlbumItem {
    static let preview = AlbumItem(
        title: "Love Dive - Single",
        artistName: "IVE",
        releaseDate: Date(),
        trackCount: 2
    )
}

extension ArtistItem {
    static let preview = ArtistItem(name: "IVE")
}
