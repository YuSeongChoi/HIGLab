import AVFoundation
import GroupActivities

// ============================================
// 재생/일시정지 동기화
// ============================================

// SharePlay 연결 후에는 play(), pause()가 자동으로 동기화됩니다.
// 별도의 코드 없이 기존 AVPlayer 코드를 그대로 사용하면 됩니다!

class SynchronizedPlaybackController {
    let player: AVPlayer
    private var session: GroupSession<WatchTogetherActivity>?
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    func connectToSharePlay(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
        player.playbackCoordinator.coordinateWithSession(session)
        session.join()
    }
    
    // ========== 동기화되는 동작들 ==========
    
    // 재생 → 모든 참가자가 재생
    func play() {
        player.play()
        // 별도 메시지 전송 불필요!
    }
    
    // 일시정지 → 모든 참가자가 일시정지
    func pause() {
        player.pause()
        // 별도 메시지 전송 불필요!
    }
    
    // 재생/일시정지 토글
    func togglePlayPause() {
        if player.timeControlStatus == .playing {
            pause()
        } else {
            play()
        }
    }
}

// 🎯 핵심 포인트:
// coordinateWithSession() 호출 후에는
// AVPlayer의 기존 메서드가 자동으로 동기화됩니다.
// 
// 내가 play() 호출 → 다른 참가자도 자동 재생
// 다른 참가자가 pause() 호출 → 내 플레이어도 자동 일시정지
