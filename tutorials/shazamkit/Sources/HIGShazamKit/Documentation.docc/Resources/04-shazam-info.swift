import ShazamKit

// Shazam 서비스 관련 정보
func printShazamInfo(_ item: SHMatchedMediaItem) {
    // Shazam 내부 ID
    if let shazamID = item.shazamID {
        print("🔍 Shazam ID: \(shazamID)")
    }
    
    // ISRC (국제표준녹음코드)
    if let isrc = item.isrc {
        print("🏷️ ISRC: \(isrc)")
    }
    
    // 재생 속도 차이 (frequencySkew)
    // 1.0 = 원본과 동일
    // 1.1 = 10% 빠름
    // 0.9 = 10% 느림
    if let skew = item.frequencySkew {
        let percentage = (skew - 1.0) * 100
        if abs(percentage) > 1 {
            print("⏩ 속도 차이: \(String(format: "%.1f", percentage))%")
        }
    }
    
    // 매칭 오프셋 (레퍼런스 내 위치)
    if let offset = item.matchOffset {
        print("⏱️ 매칭 위치: \(String(format: "%.1f", offset))초")
    }
}
