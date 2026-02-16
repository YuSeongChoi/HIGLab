import GroupActivities
import AVFoundation

// ============================================
// 시나리오 1: 미디어 재생 앱 (영화, 드라마, 음악)
// ============================================

// SharePlay의 가장 대표적인 사용 사례
// - Apple TV+, Disney+, Netflix 등이 이 방식 사용
// - AVPlayer와 자동 연동되어 구현이 간편

struct MovieWatchActivity: GroupActivity {
    let movie: Movie
    
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = movie.title
        meta.subtitle = "함께 시청"
        meta.type = .watchTogether  // 미디어 타입
        return meta
    }
}

// AVPlayer와 SharePlay 연동
class MediaPlayer: ObservableObject {
    let player: AVPlayer
    private var groupSession: GroupSession<MovieWatchActivity>?
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
    }
    
    func configureGroupSession(_ session: GroupSession<MovieWatchActivity>) {
        self.groupSession = session
        
        // 🎬 핵심: AVPlayer의 playbackCoordinator를 세션에 연결
        // 이 한 줄로 재생 동기화가 자동으로 처리됨!
        player.playbackCoordinator.coordinateWithSession(session)
        
        session.join()
    }
}

// 이제 한 참가자가 play(), pause(), seek()를 호출하면
// 모든 참가자의 플레이어에 자동으로 반영됩니다.
