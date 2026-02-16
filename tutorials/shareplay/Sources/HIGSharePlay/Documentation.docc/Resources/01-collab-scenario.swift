import GroupActivities
import SwiftUI

// ============================================
// 시나리오 2: 실시간 협업 앱 (화이트보드, 문서 편집)
// ============================================

// 미디어 재생이 아닌 앱 상태를 동기화
// - 화이트보드 드로잉
// - 문서 공동 편집
// - 프레젠테이션 공유

struct CollaborationActivity: GroupActivity {
    let documentId: String
    
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = "문서 공동 편집"
        meta.type = .generic  // 일반 타입
        return meta
    }
}

// 화이트보드 예시: 드로잉 데이터를 동기화
struct DrawingPoint: Codable {
    let x: Double
    let y: Double
    let timestamp: Date
    let participantId: UUID
}

class WhiteboardManager: ObservableObject {
    @Published var points: [DrawingPoint] = []
    
    private var groupSession: GroupSession<CollaborationActivity>?
    private var messenger: GroupSessionMessenger?
    
    func configureSession(_ session: GroupSession<CollaborationActivity>) {
        self.groupSession = session
        self.messenger = GroupSessionMessenger(session: session)
        
        session.join()
        
        // 다른 참가자의 드로잉 수신
        Task {
            guard let messenger else { return }
            for await (point, _) in messenger.messages(of: DrawingPoint.self) {
                await MainActor.run {
                    self.points.append(point)
                }
            }
        }
    }
    
    // 드로잉 포인트 전송
    func sendPoint(_ point: DrawingPoint) async throws {
        try await messenger?.send(point)
    }
}
