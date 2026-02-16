import AVFoundation
import GroupActivities

// ============================================
// AVPlaybackCoordinator 소개
// ============================================

// AVPlayer는 iOS 15+에서 기본적으로 playbackCoordinator를 제공합니다.
// 이를 통해 SharePlay와 자동으로 연동됩니다.

class MediaPlayer {
    let player: AVPlayer
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
        
        // playbackCoordinator에 접근
        let coordinator = player.playbackCoordinator
        
        // coordinator의 타입
        print(type(of: coordinator)) // AVPlaybackCoordinator
    }
}

// AVPlaybackCoordinator의 주요 역할:
// 1️⃣ 재생 상태 동기화 (play, pause)
// 2️⃣ 재생 위치 동기화 (seek)
// 3️⃣ 재생 속도 동기화
// 4️⃣ 버퍼링 상태 조율

// coordinateWithSession() 호출 전후 비교:
// 
// 호출 전: player.play() → 로컬에서만 재생
// 호출 후: player.play() → 모든 참가자가 재생
