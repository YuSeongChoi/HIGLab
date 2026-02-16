import GroupActivities
import AVFoundation
import Combine

// ============================================
// GroupActivities 프레임워크 핵심 구성요소
// ============================================

// 1️⃣ GroupActivity
// 공유 가능한 활동을 정의하는 프로토콜
struct WatchTogetherActivity: GroupActivity {
    let movie: Movie
    
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = movie.title
        meta.type = .watchTogether
        return meta
    }
}

// 2️⃣ GroupSession
// 활동 세션을 관리하는 클래스
// - state: 세션 상태 (waiting, joined, invalidated)
// - activeParticipants: 참여 중인 사용자 목록
// - join(): 세션 참여
// - leave(): 세션 떠나기

// 3️⃣ GroupSessionMessenger
// 참가자 간 메시지 교환
// - send(_:): 메시지 전송
// - messages(of:): 메시지 수신

// 4️⃣ AVPlaybackCoordinator
// AVPlayer와 SharePlay 연동
// - 재생 동기화 자동 처리

// 사용 예시
class SharePlayManager: ObservableObject {
    private var groupSession: GroupSession<WatchTogetherActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    
    func configureSession(_ session: GroupSession<WatchTogetherActivity>) {
        self.groupSession = session
        self.messenger = GroupSessionMessenger(session: session)
        
        // 세션 참여
        session.join()
    }
}
