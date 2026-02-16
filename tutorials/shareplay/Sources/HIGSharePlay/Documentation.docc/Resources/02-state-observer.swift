import GroupActivities
import SwiftUI
import Combine

// ============================================
// GroupStateObserver: SharePlay 가용성 모니터링
// ============================================

@MainActor
class SharePlayStateManager: ObservableObject {
    
    // SharePlay 가능 여부
    @Published var isEligible = false
    
    // GroupStateObserver 인스턴스
    private let stateObserver = GroupStateObserver()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        observeEligibility()
    }
    
    private func observeEligibility() {
        // isEligibleForGroupSession 프로퍼티 관찰
        // - true: FaceTime 통화 중이거나 메시지 SharePlay 세션 활성화
        // - false: SharePlay 불가능한 상태
        
        stateObserver.$isEligibleForGroupSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEligible in
                self?.isEligible = isEligible
                
                if isEligible {
                    print("✅ SharePlay 사용 가능!")
                } else {
                    print("❌ SharePlay 사용 불가")
                }
            }
            .store(in: &subscriptions)
    }
}

// SwiftUI에서 사용
struct MovieDetailView: View {
    @StateObject private var stateManager = SharePlayStateManager()
    let movie: Movie
    
    var body: some View {
        VStack {
            // 영화 정보...
            
            // SharePlay 버튼 (가능할 때만 활성화)
            Button {
                startSharePlay()
            } label: {
                Label("SharePlay", systemImage: "shareplay")
            }
            .disabled(!stateManager.isEligible)
            
            // 상태 표시
            if !stateManager.isEligible {
                Text("FaceTime 통화 중에 SharePlay를 사용할 수 있습니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func startSharePlay() {
        Task {
            let activity = WatchTogetherActivity(movie: movie)
            _ = try? await activity.activate()
        }
    }
}
