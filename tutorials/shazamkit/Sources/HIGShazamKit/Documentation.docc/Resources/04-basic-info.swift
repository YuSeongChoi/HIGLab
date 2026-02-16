import ShazamKit

// SHMatchedMediaItem 기본 곡 정보
func printBasicInfo(_ item: SHMatchedMediaItem) {
    // 곡 제목
    if let title = item.title {
        print("🎵 제목: \(title)")
    }
    
    // 아티스트
    if let artist = item.artist {
        print("🎤 아티스트: \(artist)")
    }
    
    // 부제목 (있는 경우)
    if let subtitle = item.subtitle {
        print("📝 부제목: \(subtitle)")
    }
    
    // 명시적 콘텐츠 여부
    if item.isExplicit {
        print("⚠️ 19금 콘텐츠")
    }
}
