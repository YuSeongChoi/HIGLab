import ShazamKit

// SHMatchedMediaItem에서 정보 추출하기
func extractSongInfo(from item: SHMatchedMediaItem) {
    // 기본 정보
    let title = item.title ?? "알 수 없는 곡"
    let artist = item.artist ?? "알 수 없는 아티스트"
    let album = item.albumTitle ?? "알 수 없는 앨범"
    
    // 앨범 아트
    if let artworkURL = item.artworkURL {
        // URL에서 {w}와 {h}를 원하는 크기로 교체
        let imageURL = formatArtworkURL(artworkURL, width: 300, height: 300)
        print("앨범 아트: \(imageURL)")
    }
    
    // Apple Music 연동
    if let appleMusicURL = item.appleMusicURL {
        print("Apple Music에서 듣기: \(appleMusicURL)")
    }
    
    if let appleMusicID = item.appleMusicID {
        print("Apple Music ID: \(appleMusicID)")
    }
    
    // 장르
    let genres = item.genres
    print("장르: \(genres.joined(separator: ", "))")
}

func formatArtworkURL(_ url: URL, width: Int, height: Int) -> URL {
    let string = url.absoluteString
        .replacingOccurrences(of: "{w}", with: "\(width)")
        .replacingOccurrences(of: "{h}", with: "\(height)")
    return URL(string: string) ?? url
}
