import GroupActivities

struct WatchTogetherActivity: GroupActivity {
    let movie: Movie
    
    // ============================================
    // GroupActivityMetadata 상세 설정
    // ============================================
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        
        // 필수: 활동 제목
        meta.title = movie.title
        
        // 선택: 부제목
        meta.subtitle = "\(movie.releaseYear)년 • \(movie.runtime)분"
        
        // 선택: 활동 타입
        // - .watchTogether: 미디어 시청 (가장 일반적)
        // - .listenTogether: 음악 감상
        // - .generic: 기타 (게임, 협업 등)
        meta.type = .watchTogether
        
        // 선택: 폴백 URL (앱이 없는 참가자용)
        meta.fallbackURL = URL(string: "https://example.com/movie/\(movie.id)")
        
        // 선택: 지원 기기
        meta.supportsContinuationOnTV = true
        
        return meta
    }
}

// 💡 metadata는 시스템 UI에 표시됩니다:
// - FaceTime SharePlay 시트
// - 메시지 앱의 SharePlay 카드
// - Control Center의 Now Playing
