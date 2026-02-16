import ShazamKit

// SHManagedSession.State
// - .idle: 세션이 대기 중
// - .prerecording: 녹음 준비 중
// - .matching: 매칭 진행 중

@available(iOS 17.0, *)
extension MusicRecognizer {
    /// 세션 상태에 따른 UI 업데이트
    func updateUIForSessionState(_ sessionState: SHManagedSession.State) {
        switch sessionState {
        case .idle:
            // 대기 상태 - 시작 버튼 활성화
            state = .idle
            
        case .prerecording:
            // 녹음 준비 중
            state = .listening
            
        case .matching:
            // 매칭 중
            state = .matching
            
        @unknown default:
            break
        }
    }
}
