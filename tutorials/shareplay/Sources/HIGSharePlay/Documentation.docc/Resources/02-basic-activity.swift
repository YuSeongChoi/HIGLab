import GroupActivities

// ============================================
// GroupActivity 프로토콜 기본 구현
// ============================================

// GroupActivity를 채택하는 구조체
// ⚠️ Codable도 반드시 채택해야 함 (네트워크 전송)
struct WatchTogetherActivity: GroupActivity {
    
    // 함께 볼 영화 정보
    let movie: Movie
    
    // 필수 구현: metadata 프로퍼티
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = movie.title
        return meta
    }
}

// ✅ GroupActivity 요구사항:
// 1. Codable 채택 (자동으로 요구됨)
// 2. metadata 계산 프로퍼티 구현
// 3. Hashable 채택 (자동으로 요구됨)
