import Foundation
import ShazamKit

// MARK: - MatchedSong
// ShazamKit으로 인식된 곡 정보를 담는 모델

struct MatchedSong: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String           // 곡 제목
    let artist: String          // 아티스트
    let artworkURL: URL?        // 앨범 아트 URL
    let appleMusicURL: URL?     // Apple Music 링크
    let shazamID: String?       // Shazam 고유 ID
    let genres: [String]        // 장르 목록
    let matchedAt: Date         // 인식된 시간
    
    // MARK: - SHMediaItem에서 변환
    init(from mediaItem: SHMediaItem) {
        self.id = UUID()
        self.title = mediaItem.title ?? "알 수 없는 곡"
        self.artist = mediaItem.artist ?? "알 수 없는 아티스트"
        self.artworkURL = mediaItem.artworkURL
        self.appleMusicURL = mediaItem.appleMusicURL
        self.shazamID = mediaItem.shazamID
        self.genres = mediaItem.genres
        self.matchedAt = Date()
    }
    
    // MARK: - 미리보기용 초기화
    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        artworkURL: URL? = nil,
        appleMusicURL: URL? = nil,
        shazamID: String? = nil,
        genres: [String] = [],
        matchedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.appleMusicURL = appleMusicURL
        self.shazamID = shazamID
        self.genres = genres
        self.matchedAt = matchedAt
    }
}

// MARK: - 미리보기 데이터
extension MatchedSong {
    static let preview = MatchedSong(
        title: "Blinding Lights",
        artist: "The Weeknd",
        artworkURL: URL(string: "https://example.com/artwork.jpg"),
        genres: ["Pop", "Synth-pop"]
    )
    
    static let previewList: [MatchedSong] = [
        MatchedSong(title: "Blinding Lights", artist: "The Weeknd", genres: ["Pop"]),
        MatchedSong(title: "Shape of You", artist: "Ed Sheeran", genres: ["Pop"]),
        MatchedSong(title: "Dynamite", artist: "BTS", genres: ["K-Pop", "Dance"])
    ]
}
