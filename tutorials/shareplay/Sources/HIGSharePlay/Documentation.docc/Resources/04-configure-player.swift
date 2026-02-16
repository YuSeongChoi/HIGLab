import AVFoundation
import GroupActivities

// ============================================
// Coordinated Playback을 위한 AVPlayer 설정
// ============================================

class SharePlayConfiguredPlayer {
    let player: AVPlayer
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
        configureForSharePlay()
    }
    
    private func configureForSharePlay() {
        // 1️⃣ 자동 재생 대기 활성화
        // - 모든 참가자가 준비될 때까지 재생을 자동으로 대기
        player.automaticallyWaitsToMinimizeStalling = true
        
        // 2️⃣ 볼륨 설정 (각자 조절 가능)
        player.volume = 1.0
        
        // 3️⃣ 음소거 상태 (개인 설정)
        player.isMuted = false
        
        // ⚠️ 볼륨과 음소거는 동기화되지 않음!
        // 각 참가자가 개별적으로 조절 가능
    }
    
    func connectToSession(_ session: GroupSession<WatchTogetherActivity>) {
        // Coordinator 연결
        player.playbackCoordinator.coordinateWithSession(session)
        
        session.join()
        
        // 영상 로드 후 자동 재생 시작
        let movie = session.activity.movie
        let item = AVPlayerItem(url: movie.videoURL)
        player.replaceCurrentItem(with: item)
        
        // play() 호출 - 모든 참가자가 준비되면 재생 시작
        player.play()
    }
}

// 💡 Tip: automaticallyWaitsToMinimizeStalling = true 설정 시
// 한 참가자의 버퍼링으로 인해 다른 참가자도 대기합니다.
// 모두가 같은 위치에서 함께 볼 수 있도록 보장합니다.
