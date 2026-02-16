import ShazamKit

@available(iOS 17.0, *)
class DeduplicatingMatcher {
    private let session = SHManagedSession()
    private var lastMatchedID: String?
    private var lastMatchTime: Date?
    
    // 같은 곡 중복 인식 방지 시간 (초)
    private let deduplicationInterval: TimeInterval = 30
    
    func processMatch(_ match: SHMatch) -> Song? {
        guard let item = match.mediaItems.first else { return nil }
        
        let currentID = item.shazamID ?? item.appleMusicID ?? item.title ?? ""
        let now = Date()
        
        // 중복 체크
        if let lastID = lastMatchedID,
           let lastTime = lastMatchTime,
           lastID == currentID,
           now.timeIntervalSince(lastTime) < deduplicationInterval {
            // 중복 - 무시
            print("중복 감지, 무시: \(item.title ?? "")")
            return nil
        }
        
        // 새로운 매칭!
        lastMatchedID = currentID
        lastMatchTime = now
        
        return Song(from: item)
    }
    
    /// 중복 상태 초기화
    func resetDeduplication() {
        lastMatchedID = nil
        lastMatchTime = nil
    }
}
