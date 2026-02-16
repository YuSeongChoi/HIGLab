import ShazamKit

@available(iOS 17.0, *)
class SingleMatchExample {
    let session = SHManagedSession()
    
    /// 한 번의 인식 시도
    func recognizeOnce() async -> Song? {
        // result()는 매칭이 완료될 때까지 대기
        let result = await session.result()
        
        switch result {
        case .match(let match):
            // 첫 번째 매칭 결과 반환
            if let mediaItem = match.mediaItems.first {
                return Song(from: mediaItem)
            }
            return nil
            
        case .noMatch:
            // 카탈로그에 없는 곡
            return nil
            
        case .error:
            // 오류 발생
            return nil
        }
    }
}
