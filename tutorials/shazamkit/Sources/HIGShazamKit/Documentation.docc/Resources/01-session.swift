import ShazamKit

// SHSession - 매칭의 핵심 클래스
class MusicMatcher {
    let session = SHSession()
    
    init() {
        // 델리게이트 설정
        session.delegate = self
    }
    
    // 시그니처로 매칭 요청
    func match(signature: SHSignature) {
        session.match(signature)
    }
}

extension MusicMatcher: SHSessionDelegate {
    // 매칭 성공
    func session(_ session: SHSession, didFind match: SHMatch) {
        print("매칭 성공: \(match.mediaItems.first?.title ?? "")")
    }
    
    // 매칭 실패
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("매칭 실패")
    }
}
