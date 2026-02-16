import ShazamKit

// SHManagedSession - 가장 쉬운 방법 (iOS 17+)
@available(iOS 17.0, *)
class SimpleMusicRecognizer {
    let session = SHManagedSession()
    
    func recognize() async {
        // 한 줄로 음악 인식!
        // 마이크 접근, 시그니처 생성 모두 자동
        let result = await session.result()
        
        switch result {
        case .match(let match):
            if let firstItem = match.mediaItems.first {
                print("🎵 \(firstItem.title ?? "알 수 없음")")
                print("🎤 \(firstItem.artist ?? "알 수 없음")")
            }
        case .noMatch:
            print("매칭되는 곡이 없습니다")
        case .error(let error, _):
            print("오류: \(error.localizedDescription)")
        }
    }
}
