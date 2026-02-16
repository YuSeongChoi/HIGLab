import GroupActivities
import Combine
import SwiftUI

// ============================================
// 세션 Invalidation 처리
// ============================================

@MainActor
class SessionInvalidationHandler: ObservableObject {
    @Published var isSessionInvalidated = false
    @Published var invalidationReason: String?
    
    private var session: GroupSession<WatchTogetherActivity>?
    private var subscriptions = Set<AnyCancellable>()
    
    func observeSession(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
        
        session.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if state == .invalidated {
                    self?.handleInvalidation()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func handleInvalidation() {
        isSessionInvalidated = true
        
        // 세션이 무효화된 이유 (추정)
        // - 모든 참가자가 나감
        // - FaceTime 통화 종료
        // - 네트워크 문제
        // - 앱이 백그라운드로 이동 후 오래 지속
        
        print("⚠️ 세션이 무효화되었습니다")
        
        // UI 초기화
        resetToInitialState()
    }
    
    private func resetToInitialState() {
        // 재생 중지
        // 참가자 목록 초기화
        // 메인 화면으로 이동 등
        
        invalidationReason = "SharePlay 세션이 종료되었습니다"
    }
}

// SwiftUI 알림 예시
struct PlayerView: View {
    @StateObject private var handler = SessionInvalidationHandler()
    
    var body: some View {
        VideoPlayerView()
            .alert(
                "세션 종료",
                isPresented: $handler.isSessionInvalidated
            ) {
                Button("확인") {
                    // 메인 화면으로 이동
                }
            } message: {
                Text(handler.invalidationReason ?? "")
            }
    }
}

struct VideoPlayerView: View {
    var body: some View {
        Color.black // 플레이어 플레이스홀더
    }
}
