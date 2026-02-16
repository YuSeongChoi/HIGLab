import GroupActivities
import Combine

// ============================================
// GroupSession 주요 프로퍼티
// ============================================

func exploreSessionProperties(_ session: GroupSession<WatchTogetherActivity>) {
    
    // 1️⃣ activity: 세션의 Activity 정보
    let activity = session.activity
    let movie = activity.movie
    print("현재 활동: \(movie.title)")
    
    // 2️⃣ state: 세션의 현재 상태
    // - .waiting: 생성됨, 아직 join() 안 함
    // - .joined: 세션에 참여 완료
    // - .invalidated: 세션 종료됨 (더 이상 사용 불가)
    let state = session.state
    switch state {
    case .waiting:
        print("⏳ 대기 중...")
    case .joined:
        print("✅ 참여 완료")
    case .invalidated:
        print("❌ 세션 종료됨")
    @unknown default:
        break
    }
    
    // 3️⃣ activeParticipants: 현재 참여 중인 사용자들
    let participants = session.activeParticipants
    print("참가자 수: \(participants.count)명")
    
    for participant in participants {
        // 각 참가자의 고유 ID
        print("- \(participant.id)")
        
        // 현재 기기의 사용자인지 확인
        if participant == session.localParticipant {
            print("  (나)")
        }
    }
    
    // 4️⃣ localParticipant: 현재 기기의 사용자
    if let local = session.localParticipant {
        print("내 ID: \(local.id)")
    }
}
