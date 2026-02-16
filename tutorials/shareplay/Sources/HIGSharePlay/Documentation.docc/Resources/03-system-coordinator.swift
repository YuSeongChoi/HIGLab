import GroupActivities
import AVFoundation

// ============================================
// System Coordinator 연결
// ============================================

// AVPlayer의 playbackCoordinator를 사용해 재생 동기화
class MediaPlaybackManager {
    let player: AVPlayer
    private var session: GroupSession<WatchTogetherActivity>?
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
    }
    
    func connectToSession(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
        
        // 🎯 핵심: coordinateWithSession으로 연결
        // 이 한 줄로 재생 동기화가 자동으로 처리됨
        player.playbackCoordinator.coordinateWithSession(session)
        
        // 이제 play(), pause(), seek()가 모든 참가자에게 동기화됨
        session.join()
    }
    
    // 재생 시작 (모든 참가자 동기화)
    func play() {
        player.play()
    }
    
    // 일시정지 (모든 참가자 동기화)
    func pause() {
        player.pause()
    }
    
    // 탐색 (모든 참가자 동기화)
    func seek(to time: CMTime) {
        player.seek(to: time)
    }
}

// ⚠️ coordinateWithSession 호출 후에는:
// - player.play() → 모든 참가자가 재생 시작
// - player.pause() → 모든 참가자가 일시정지
// - player.seek(to:) → 모든 참가자가 같은 위치로 이동
// 
// 별도의 메시지 전송 없이 자동으로 동기화됩니다!
