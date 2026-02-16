import AVFoundation
import GroupActivities
import SwiftUI

// ============================================
// 참가자별 재생 상태 표시
// ============================================

// 참가자 재생 상태
struct ParticipantPlaybackStatus: Identifiable {
    let id: UUID
    let participant: Participant
    var isPlaying: Bool
    var isBuffering: Bool
    var currentTime: CMTime
}

@MainActor
class ParticipantPlaybackTracker: ObservableObject {
    @Published var statuses: [ParticipantPlaybackStatus] = []
    
    private var session: GroupSession<WatchTogetherActivity>?
    private var messenger: GroupSessionMessenger?
    
    func configure(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
        self.messenger = GroupSessionMessenger(session: session)
        
        // 내 상태를 주기적으로 브로드캐스트
        startBroadcastingMyStatus()
        
        // 다른 참가자의 상태 수신
        receiveOtherStatuses()
    }
    
    private func startBroadcastingMyStatus() {
        // 5초마다 내 재생 상태 전송
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task {
                await self?.broadcastMyStatus()
            }
        }
    }
    
    private func broadcastMyStatus() async {
        guard let messenger else { return }
        
        let status = PlaybackStatusMessage(
            isPlaying: true,
            isBuffering: false,
            currentTimeSeconds: 120.0
        )
        
        try? await messenger.send(status)
    }
    
    private func receiveOtherStatuses() {
        guard let messenger else { return }
        
        Task {
            for await (message, context) in messenger.messages(of: PlaybackStatusMessage.self) {
                handleStatusUpdate(message, from: context.source)
            }
        }
    }
    
    private func handleStatusUpdate(_ message: PlaybackStatusMessage, from participant: Participant) {
        // 상태 업데이트
        if let index = statuses.firstIndex(where: { $0.participant == participant }) {
            statuses[index].isPlaying = message.isPlaying
            statuses[index].isBuffering = message.isBuffering
        } else {
            statuses.append(ParticipantPlaybackStatus(
                id: UUID(),
                participant: participant,
                isPlaying: message.isPlaying,
                isBuffering: message.isBuffering,
                currentTime: CMTime(seconds: message.currentTimeSeconds, preferredTimescale: 1)
            ))
        }
    }
}

struct PlaybackStatusMessage: Codable {
    let isPlaying: Bool
    let isBuffering: Bool
    let currentTimeSeconds: Double
}
