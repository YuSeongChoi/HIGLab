import ShazamKit

extension Song {
    /// SHMatchedMediaItem에서 Song 생성
    init(from mediaItem: SHMatchedMediaItem) {
        // ID 생성 (Shazam ID > Apple Music ID > 제목+아티스트)
        let songID = mediaItem.shazamID
            ?? mediaItem.appleMusicID
            ?? "\(mediaItem.title ?? "")_\(mediaItem.artist ?? "")"
        
        self.init(
            id: songID,
            title: mediaItem.title ?? "알 수 없는 곡",
            artist: mediaItem.artist ?? "알 수 없는 아티스트",
            albumTitle: mediaItem.albumTitle,
            artworkURL: mediaItem.artworkURL,
            appleMusicURL: mediaItem.appleMusicURL,
            appleMusicID: mediaItem.appleMusicID,
            genres: mediaItem.genres,
            isExplicit: mediaItem.isExplicit,
            recognizedAt: Date()
        )
    }
}

// 사용 예시
func createSongFromMatch(_ match: SHMatch) -> Song? {
    guard let mediaItem = match.mediaItems.first else { return nil }
    return Song(from: mediaItem)
}
