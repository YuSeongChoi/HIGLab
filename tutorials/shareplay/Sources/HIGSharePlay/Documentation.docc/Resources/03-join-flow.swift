import GroupActivities
import AVFoundation
import Combine

// ============================================
// 세션 참여 순서 (Join Flow)
// ============================================

// 올바른 순서:
// 1. 세션 수신 (sessions() AsyncSequence)
// 2. 세션 설정 (coordinator 연결, messenger 생성 등)
// 3. 세션 참여 (join())

class SharePlayCoordinator: ObservableObject {
    private var session: GroupSession<WatchTogetherActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    
    let player = AVPlayer()
    
    // 세션 수신 및 설정
    func handleSession(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
        
        // ===== STEP 1: 설정 먼저! =====
        
        // 1-1. AVPlayer와 세션 연결 (재생 동기화)
        player.playbackCoordinator.coordinateWithSession(session)
        
        // 1-2. Messenger 생성 (메시지 송수신)
        self.messenger = GroupSessionMessenger(session: session)
        
        // 1-3. 상태 관찰 설정
        session.$state
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &subscriptions)
        
        // 1-4. 참가자 관찰 설정
        session.$activeParticipants
            .sink { [weak self] participants in
                self?.handleParticipantsChange(participants)
            }
            .store(in: &subscriptions)
        
        // ===== STEP 2: 설정 완료 후 join() =====
        session.join()
        
        print("✅ 세션 참여 완료!")
    }
    
    private func handleStateChange(_ state: GroupSession<WatchTogetherActivity>.State) {
        // 상태 변화 처리
    }
    
    private func handleParticipantsChange(_ participants: Set<Participant>) {
        // 참가자 변화 처리
    }
}

// ⚠️ 주의: join() 전에 모든 설정을 완료해야 함!
// join() 후에 설정하면 일부 이벤트를 놓칠 수 있음
