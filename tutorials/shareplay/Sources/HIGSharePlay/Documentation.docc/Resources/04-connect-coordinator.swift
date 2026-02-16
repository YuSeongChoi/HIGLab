import AVFoundation
import GroupActivities

// ============================================
// PlaybackCoordinator와 GroupSession 연결
// ============================================

class CoordinatedPlayer {
    let player: AVPlayer
    private var session: GroupSession<WatchTogetherActivity>?
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
    }
    
    func connectToSharePlay(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
        
        // 🎯 핵심 API: coordinateWithSession
        // AVPlaybackCoordinator를 GroupSession에 연결
        player.playbackCoordinator.coordinateWithSession(session)
        
        // 이제부터 모든 재생 제어가 동기화됩니다!
        
        session.join()
    }
    
    // 연결 해제
    func disconnect() {
        // 세션에서 나가면 자동으로 연결 해제
        session?.leave()
    }
}

// 실제 사용 예시
func setupSharePlayPlayer() async {
    let player = CoordinatedPlayer(url: URL(string: "https://example.com/video.mp4")!)
    
    // 세션 수신 대기
    for await session in WatchTogetherActivity.sessions() {
        player.connectToSharePlay(session)
        break // 첫 세션만 처리
    }
}
