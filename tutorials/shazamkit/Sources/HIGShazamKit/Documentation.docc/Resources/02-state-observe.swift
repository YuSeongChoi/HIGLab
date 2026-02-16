import ShazamKit

@available(iOS 17.0, *)
extension MusicRecognizer {
    /// 세션 상태 변화를 관찰합니다
    func observeSessionState() {
        Task {
            for await sessionState in session.state {
                await MainActor.run {
                    updateUIForSessionState(sessionState)
                }
            }
        }
    }
}

// 사용 예시
/*
@Observable
class MusicRecognizer {
    private let session = SHManagedSession()
    
    init() {
        // 초기화 시 상태 관찰 시작
        observeSessionState()
    }
}
*/
