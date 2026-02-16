import ShazamKit

// SHMatchedMediaItem 앨범 정보
func printAlbumInfo(_ item: SHMatchedMediaItem) {
    // 앨범 제목
    if let albumTitle = item.albumTitle {
        print("💿 앨범: \(albumTitle)")
    }
    
    // 앨범 아트 URL
    if let artworkURL = item.artworkURL {
        print("🖼️ 아트워크: \(artworkURL)")
    }
    
    // 장르 (배열)
    let genres = item.genres
    if !genres.isEmpty {
        print("🎸 장르: \(genres.joined(separator: ", "))")
    }
    
    // 발매일 (있는 경우)
    if let creationDate = item.creationDate {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        print("📅 발매일: \(formatter.string(from: creationDate))")
    }
}
