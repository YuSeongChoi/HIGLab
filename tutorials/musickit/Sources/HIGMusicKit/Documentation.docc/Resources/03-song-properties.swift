import MusicKit

// Song의 주요 속성들

func printSongDetails(_ song: Song) {
    // 기본 정보
    print("제목: \(song.title)")
    print("아티스트: \(song.artistName)")
    
    // 앨범 정보 (옵셔널)
    if let albumTitle = song.albumTitle {
        print("앨범: \(albumTitle)")
    }
    
    // 재생 시간
    if let duration = song.duration {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        print("길이: \(minutes):\(String(format: "%02d", seconds))")
    }
    
    // 트랙 번호
    if let trackNumber = song.trackNumber {
        print("트랙: \(trackNumber)")
    }
    
    // 디스크 번호
    if let discNumber = song.discNumber {
        print("디스크: \(discNumber)")
    }
    
    // 발매일
    if let releaseDate = song.releaseDate {
        print("발매일: \(releaseDate)")
    }
    
    // 장르
    if let genreNames = song.genreNames.first {
        print("장르: \(genreNames)")
    }
    
    // 19금 콘텐츠 여부
    if song.contentRating == .explicit {
        print("⚠️ 성인용 콘텐츠")
    }
    
    // 아트워크 (별도 표시)
    if song.artwork != nil {
        print("🖼️ 아트워크 있음")
    }
}
