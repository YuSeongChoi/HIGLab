import GroupActivities
import AVFoundation
import Combine

// ============================================
// 세션 참여 상세 구현
// ============================================

class SessionManager {
    private var session: GroupSession<WatchTogetherActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    
    let player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    func join(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
        
        // ========== 1. Coordinator 연결 ==========
        // AVPlayer와 세션 연결
        player.playbackCoordinator.coordinateWithSession(session)
        
        // ========== 2. Messenger 설정 ==========
        let messenger = GroupSessionMessenger(session: session)
        self.messenger = messenger
        
        // 메시지 수신 시작
        Task {
            for await (message, context) in messenger.messages(of: ChatMessage.self) {
                await handleChatMessage(message, from: context.source)
            }
        }
        
        // ========== 3. 관찰자 설정 ==========
        // 상태 관찰
        session.$state
            .sink { [weak self] state in
                self?.onStateChanged(state)
            }
            .store(in: &subscriptions)
        
        // 참가자 관찰
        session.$activeParticipants
            .sink { [weak self] participants in
                self?.onParticipantsChanged(participants)
            }
            .store(in: &subscriptions)
        
        // ========== 4. 세션 참여 ==========
        // 모든 설정이 완료된 후 join() 호출
        session.join()
        
        print("✅ 세션 참여 완료")
    }
    
    private func onStateChanged(_ state: GroupSession<WatchTogetherActivity>.State) {
        switch state {
        case .joined:
            print("🟢 세션 활성화")
        case .invalidated:
            print("🔴 세션 종료됨")
        default:
            break
        }
    }
    
    private func onParticipantsChanged(_ participants: Set<Participant>) {
        print("👥 참가자: \(participants.count)명")
    }
    
    @MainActor
    private func handleChatMessage(_ message: ChatMessage, from participant: Participant) {
        print("💬 \(message.text)")
    }
}

struct ChatMessage: Codable {
    let text: String
}
