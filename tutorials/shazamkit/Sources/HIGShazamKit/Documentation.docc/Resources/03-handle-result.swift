import ShazamKit

@available(iOS 17.0, *)
extension MusicRecognizer {
    /// 매칭 결과를 처리하고 적절한 피드백 제공
    @MainActor
    func handleMatchResult(_ result: SHSession.Result) {
        switch result {
        case .match(let match):
            // 성공 - 곡 정보 표시
            if let item = match.mediaItems.first {
                currentSong = Song(from: item)
                state = .matched
                // 햅틱 피드백
                playSuccessHaptic()
            }
            
        case .noMatch(let signature):
            // 실패 - 다시 시도 안내
            state = .noMatch
            errorMessage = "이 곡을 찾을 수 없습니다. 더 가까이서 다시 시도해보세요."
            // 시그니처 저장 (나중에 커스텀 카탈로그에 추가 가능)
            saveUnmatchedSignature(signature)
            
        case .error(let error, _):
            // 오류 - 사용자에게 안내
            state = .error(error.localizedDescription)
            handleError(error)
        }
    }
    
    private func playSuccessHaptic() {
        // UIImpactFeedbackGenerator 등 사용
    }
    
    private func saveUnmatchedSignature(_ signature: SHSignature) {
        // 로컬에 저장해두고 나중에 활용
    }
    
    private func handleError(_ error: Error) {
        // 에러 타입에 따른 처리
    }
}
