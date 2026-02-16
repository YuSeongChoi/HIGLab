import ShazamKit

@available(iOS 17.0, *)
@Observable
class BackgroundMatcher {
    private let session = SHManagedSession()
    private var matchTask: Task<Void, Never>?
    
    var isRunning = false
    var matchedSongs: [Song] = []
    
    /// 백그라운드에서 연속 매칭 시작
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        matchTask = Task {
            for await result in session.results {
                guard !Task.isCancelled else { break }
                
                if case .match(let match) = result,
                   let item = match.mediaItems.first {
                    await MainActor.run {
                        let song = Song(from: item)
                        matchedSongs.append(song)
                    }
                }
            }
        }
    }
    
    /// 매칭 중지
    func stop() {
        matchTask?.cancel()
        matchTask = nil
        session.cancel()
        isRunning = false
    }
    
    deinit {
        stop()
    }
}
