import Foundation
import ShazamKit

/// 앱에서 사용할 곡 모델
struct Song: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let albumTitle: String?
    let artworkURL: URL?
    let appleMusicURL: URL?
    let appleMusicID: String?
    let genres: [String]
    let isExplicit: Bool
    let recognizedAt: Date
    
    // Codable을 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case id, title, artist, albumTitle, artworkURL
        case appleMusicURL, appleMusicID, genres, isExplicit, recognizedAt
    }
}

extension Song {
    /// 특정 크기의 앨범 아트 URL 생성
    func artworkURL(width: Int, height: Int) -> URL? {
        guard let url = artworkURL else { return nil }
        let string = url.absoluteString
            .replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
        return URL(string: string)
    }
}
