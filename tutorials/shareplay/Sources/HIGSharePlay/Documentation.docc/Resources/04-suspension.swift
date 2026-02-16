import AVFoundation
import GroupActivities
import Combine

// ============================================
// 재생 중단 원인 (Suspension Reasons)
// ============================================

class SuspensionReasonTracker: ObservableObject {
    @Published var suspensionReasons: [String] = []
    @Published var canPlay = true
    
    let player: AVPlayer
    private var subscriptions = Set<AnyCancellable>()
    
    init(player: AVPlayer) {
        self.player = player
        observeSuspensionReasons()
    }
    
    private func observeSuspensionReasons() {
        // playbackCoordinator의 suspensionReasons 관찰
        player.playbackCoordinator.publisher(for: \.suspensionReasons)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reasons in
                self?.handleSuspensionReasons(reasons)
            }
            .store(in: &subscriptions)
    }
    
    private func handleSuspensionReasons(_ reasons: [AVCoordinatedPlaybackSuspension.Reason]) {
        suspensionReasons = reasons.map { reason in
            switch reason {
            case .audioSessionInterrupted:
                return "🔊 오디오 세션 중단됨"
            case .stallRecovery:
                return "📶 네트워크 복구 중"
            case .playingInterstitial:
                return "📺 광고 재생 중"
            case .coordinatedPlaybackNotPossible:
                return "⚠️ 동기화 불가"
            case .userActionRequired:
                return "👆 사용자 조작 필요"
            case .userIsChangingCurrentTime:
                return "⏩ 탐색 중"
            default:
                return "⏸ 일시 중단"
            }
        }
        
        canPlay = reasons.isEmpty
        
        if !reasons.isEmpty {
            print("⚠️ 재생 중단 이유: \(suspensionReasons)")
        }
    }
}

// SwiftUI에서 중단 이유 표시
import SwiftUI

struct SuspensionReasonView: View {
    @ObservedObject var tracker: SuspensionReasonTracker
    
    var body: some View {
        if !tracker.canPlay {
            VStack {
                ForEach(tracker.suspensionReasons, id: \.self) { reason in
                    Text(reason)
                        .font(.caption)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
