import Foundation
import ShazamKit

// artworkURL 이해하기
// 원본 URL 예시:
// https://is1-ssl.mzstatic.com/image/thumb/.../300x300bb.jpg
// 또는
// https://is1-ssl.mzstatic.com/image/thumb/.../{w}x{h}bb.jpg

/// 앨범 아트 URL을 원하는 크기로 변환
func formatArtworkURL(_ url: URL, size: Int) -> URL {
    formatArtworkURL(url, width: size, height: size)
}

func formatArtworkURL(_ url: URL, width: Int, height: Int) -> URL {
    let string = url.absoluteString
        .replacingOccurrences(of: "{w}", with: "\(width)")
        .replacingOccurrences(of: "{h}", with: "\(height)")
    return URL(string: string) ?? url
}

// 일반적인 크기 옵션
enum ArtworkSize: Int {
    case small = 100
    case medium = 300
    case large = 600
    case extraLarge = 1000
}

extension SHMatchedMediaItem {
    func artworkURL(size: ArtworkSize) -> URL? {
        guard let url = artworkURL else { return nil }
        return formatArtworkURL(url, size: size.rawValue)
    }
}
