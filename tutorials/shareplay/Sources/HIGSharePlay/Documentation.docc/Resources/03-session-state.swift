import GroupActivities
import Combine
import SwiftUI

// ============================================
// 세션 상태 변화 모니터링
// ============================================

@MainActor
class SessionStateObserver: ObservableObject {
    @Published var state: GroupSession<WatchTogetherActivity>.State = .waiting
    @Published var isActive = false
    
    private var session: GroupSession<WatchTogetherActivity>?
    private var subscriptions = Set<AnyCancellable>()
    
    func observe(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
        
        // $state 퍼블리셔로 상태 변화 관찰
        session.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.handleStateChange(newState)
            }
            .store(in: &subscriptions)
    }
    
    private func handleStateChange(_ newState: GroupSession<WatchTogetherActivity>.State) {
        self.state = newState
        
        switch newState {
        case .waiting:
            print("⏳ 세션 대기 중")
            isActive = false
            
        case .joined:
            print("✅ 세션 참여 완료!")
            isActive = true
            // 재생 시작 등 추가 작업
            
        case .invalidated:
            print("❌ 세션 종료됨")
            isActive = false
            // 정리 작업 수행
            cleanup()
            
        @unknown default:
            break
        }
    }
    
    private func cleanup() {
        subscriptions.removeAll()
        session = nil
    }
}

// SwiftUI View에서 사용
struct PlayerControlView: View {
    @StateObject private var stateObserver = SessionStateObserver()
    
    var body: some View {
        VStack {
            if stateObserver.isActive {
                Text("🟢 SharePlay 활성화")
                    .foregroundStyle(.green)
            } else {
                Text("⚪ SharePlay 비활성화")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
