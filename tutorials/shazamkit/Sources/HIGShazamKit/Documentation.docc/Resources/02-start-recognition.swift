import ShazamKit

@available(iOS 17.0, *)
extension MusicRecognizer {
    @MainActor
    func startRecognition() async {
        // 권한 확인
        guard await checkMicrophonePermission() else {
            state = .error("마이크 권한이 필요합니다")
            return
        }
        
        // 상태 업데이트
        state = .listening
        errorMessage = nil
        currentSong = nil
        
        // 음악 인식 시작
        let result = await session.result()
        
        // 결과 처리
        switch result {
        case .match(let match):
            if let mediaItem = match.mediaItems.first {
                currentSong = Song(from: mediaItem)
                state = .matched
            }
            
        case .noMatch:
            state = .noMatch
            
        case .error(let error, _):
            state = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
}
