import AVFoundation
import GroupActivities
import Combine

// ============================================
// 재생 대기 상태 처리
// ============================================

class PlaybackWaitingHandler: ObservableObject {
    @Published var isWaitingForParticipants = false
    @Published var waitingReason: String?
    
    let player: AVPlayer
    private var subscriptions = Set<AnyCancellable>()
    
    init(player: AVPlayer) {
        self.player = player
        observeWaitingState()
    }
    
    private func observeWaitingState() {
        // timeControlStatus 관찰
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleTimeControlStatus(status)
            }
            .store(in: &subscriptions)
        
        // reasonForWaitingToPlay 관찰
        player.publisher(for: \.reasonForWaitingToPlay)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reason in
                self?.handleWaitingReason(reason)
            }
            .store(in: &subscriptions)
    }
    
    private func handleTimeControlStatus(_ status: AVPlayer.TimeControlStatus) {
        switch status {
        case .paused:
            print("⏸ 일시정지됨")
        case .playing:
            print("▶️ 재생 중")
            isWaitingForParticipants = false
        case .waitingToPlayAtSpecifiedRate:
            print("⏳ 재생 대기 중...")
            isWaitingForParticipants = true
        @unknown default:
            break
        }
    }
    
    private func handleWaitingReason(_ reason: AVPlayer.WaitingReason?) {
        guard let reason else {
            waitingReason = nil
            return
        }
        
        switch reason {
        case .toMinimizeStalls:
            waitingReason = "버퍼링 중..."
        case .evaluatingBufferingRate:
            waitingReason = "네트워크 확인 중..."
        case .noItemToPlay:
            waitingReason = "재생할 항목 없음"
        case .waitingForCoordinatedPlayback:
            // SharePlay 전용 대기 이유
            waitingReason = "다른 참가자 대기 중..."
        default:
            waitingReason = "대기 중..."
        }
    }
}

// 💡 .waitingForCoordinatedPlayback
// SharePlay에서 다른 참가자가 준비될 때까지 대기하는 상태입니다.
