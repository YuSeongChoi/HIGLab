import GroupActivities
import Combine
import AVFoundation

// ============================================
// 메모리 정리 (Cleanup)
// ============================================

class SharePlaySessionManager {
    private var session: GroupSession<WatchTogetherActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var messageTasks: [Task<Void, Never>] = []
    
    let player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    func configureSession(_ session: GroupSession<WatchTogetherActivity>) {
        // 기존 세션이 있다면 먼저 정리
        cleanup()
        
        self.session = session
        self.messenger = GroupSessionMessenger(session: session)
        
        setupObservers(session)
        setupMessageHandlers()
        
        session.join()
    }
    
    private func setupObservers(_ session: GroupSession<WatchTogetherActivity>) {
        session.$state
            .sink { [weak self] state in
                if state == .invalidated {
                    self?.cleanup()
                }
            }
            .store(in: &subscriptions)
        
        session.$activeParticipants
            .sink { participants in
                // 참가자 처리
            }
            .store(in: &subscriptions)
    }
    
    private func setupMessageHandlers() {
        guard let messenger else { return }
        
        let task = Task {
            for await (message, _) in messenger.messages(of: ChatMessage.self) {
                // 메시지 처리
            }
        }
        messageTasks.append(task)
    }
    
    // ========== 정리 메서드 ==========
    func cleanup() {
        // 1. Combine subscriptions 취소
        subscriptions.removeAll()
        
        // 2. 비동기 Tasks 취소
        messageTasks.forEach { $0.cancel() }
        messageTasks.removeAll()
        
        // 3. 플레이어 정지
        player.pause()
        
        // 4. 참조 해제
        messenger = nil
        session = nil
        
        print("🧹 SharePlay 세션 정리 완료")
    }
    
    deinit {
        // deinit에서도 정리 (안전장치)
        cleanup()
    }
}

// ⚠️ 정리가 중요한 이유:
// - 메모리 누수 방지
// - 좀비 subscription 방지
// - 이전 세션의 이벤트가 새 세션에 영향 주는 것 방지
