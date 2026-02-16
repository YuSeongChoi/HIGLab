import GroupActivities

// ============================================
// 세션 종료 방법
// ============================================

class SessionEndManager {
    private var session: GroupSession<WatchTogetherActivity>?
    
    func setSession(_ session: GroupSession<WatchTogetherActivity>) {
        self.session = session
    }
    
    // ========== 방법 1: leave() ==========
    // - 현재 사용자만 세션에서 나감
    // - 다른 참가자들은 계속 시청 가능
    // - 세션 자체는 유지됨
    func leaveOnly() {
        session?.leave()
        
        // 사용 예: "나만 나가기" 버튼
        print("👋 세션에서 나갔습니다 (다른 참가자는 계속)")
    }
    
    // ========== 방법 2: end() ==========
    // - 모든 참가자에게 세션 종료 알림
    // - 전체 세션이 종료됨
    // - 모든 참가자의 세션 상태가 .invalidated로 변경
    func endForAll() {
        session?.end()
        
        // 사용 예: "모두 종료" 버튼 (호스트 기능)
        print("🛑 세션이 종료되었습니다 (모든 참가자)")
    }
}

// SwiftUI 예시
import SwiftUI

struct SessionControlView: View {
    let sessionManager: SessionEndManager
    @State private var showEndConfirmation = false
    
    var body: some View {
        HStack {
            // 나만 나가기
            Button("나가기") {
                sessionManager.leaveOnly()
            }
            
            // 전체 종료 (확인 필요)
            Button("모두 종료") {
                showEndConfirmation = true
            }
            .foregroundStyle(.red)
        }
        .confirmationDialog(
            "SharePlay 종료",
            isPresented: $showEndConfirmation
        ) {
            Button("모든 참가자 종료", role: .destructive) {
                sessionManager.endForAll()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("모든 참가자의 SharePlay가 종료됩니다.")
        }
    }
}
