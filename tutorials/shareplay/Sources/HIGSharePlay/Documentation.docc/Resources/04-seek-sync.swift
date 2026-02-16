import AVFoundation
import GroupActivities
import SwiftUI

// ============================================
// 탐색(Seek) 동기화
// ============================================

class SeekSynchronizer {
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
    
    // ========== 동기화되는 seek 동작들 ==========
    
    // 특정 시간으로 이동 → 모든 참가자가 같은 위치로
    func seek(to time: CMTime) {
        player.seek(to: time)
    }
    
    // 10초 앞으로
    func skipForward() {
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        player.seek(to: newTime)
    }
    
    // 10초 뒤로
    func skipBackward() {
        let currentTime = player.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        player.seek(to: newTime)
    }
    
    // 진행률로 이동 (슬라이더 조작)
    func seek(toProgress progress: Double) {
        guard let duration = player.currentItem?.duration,
              duration.isNumeric else { return }
        
        let totalSeconds = CMTimeGetSeconds(duration)
        let targetSeconds = totalSeconds * progress
        let targetTime = CMTime(seconds: targetSeconds, preferredTimescale: 600)
        
        player.seek(to: targetTime)
    }
}

// SwiftUI 슬라이더 예시
struct PlaybackSlider: View {
    let player: AVPlayer
    @State private var progress: Double = 0
    
    var body: some View {
        Slider(value: $progress, in: 0...1) { editing in
            if !editing {
                // 슬라이더 조작 완료 시 seek
                seekToProgress(progress)
            }
        }
    }
    
    private func seekToProgress(_ progress: Double) {
        guard let duration = player.currentItem?.duration,
              duration.isNumeric else { return }
        
        let seconds = CMTimeGetSeconds(duration) * progress
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
        // → 모든 참가자의 재생 위치가 동기화됨!
    }
}
