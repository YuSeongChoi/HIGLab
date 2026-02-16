import ShazamKit

@available(iOS 17.0, *)
class ContinuousRecognizer {
    let session = SHManagedSession()
    private var recognitionTask: Task<Void, Never>?
    
    /// 연속 매칭 시작
    func startContinuousRecognition() {
        recognitionTask = Task {
            // results는 AsyncStream<SHSession.Result>
            for await result in session.results {
                await handleResult(result)
                
                // Task가 취소되면 루프 종료
                if Task.isCancelled { break }
            }
        }
    }
    
    /// 연속 매칭 중지
    func stopContinuousRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        session.cancel()
    }
    
    @MainActor
    private func handleResult(_ result: SHSession.Result) async {
        switch result {
        case .match(let match):
            if let item = match.mediaItems.first {
                // 새로운 곡 감지!
                print("🎵 \(item.title ?? "")")
            }
        case .noMatch:
            print("매칭되지 않음")
        case .error(let error, _):
            print("오류: \(error)")
        }
    }
}
