import GroupActivities
import SwiftUI

// ============================================
// 시나리오 3: 멀티플레이어 게임
// ============================================

// 게임 상태와 플레이어 입력을 실시간 동기화
// - 대전 게임
// - 협동 게임
// - 턴제 게임

struct GameActivity: GroupActivity {
    let gameId: String
    let gameMode: GameMode
    
    enum GameMode: String, Codable {
        case versus      // 대전
        case cooperative // 협동
    }
    
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = "함께 게임하기"
        meta.type = .generic
        return meta
    }
}

// 게임 상태 모델
struct GameState: Codable {
    var board: [[Int]]
    var currentPlayer: UUID
    var scores: [UUID: Int]
}

// 플레이어 액션
enum GameAction: Codable {
    case move(x: Int, y: Int)
    case attack(targetId: UUID)
    case useItem(itemId: String)
    case endTurn
}

class GameManager: ObservableObject {
    @Published var gameState: GameState?
    
    private var groupSession: GroupSession<GameActivity>?
    private var messenger: GroupSessionMessenger?
    
    func configureSession(_ session: GroupSession<GameActivity>) {
        self.groupSession = session
        self.messenger = GroupSessionMessenger(session: session)
        
        session.join()
        
        // 다른 플레이어의 액션 수신
        Task {
            guard let messenger else { return }
            for await (action, context) in messenger.messages(of: GameAction.self) {
                await handleAction(action, from: context.source)
            }
        }
    }
    
    func sendAction(_ action: GameAction) async throws {
        try await messenger?.send(action)
    }
    
    @MainActor
    private func handleAction(_ action: GameAction, from participant: Participant) {
        // 게임 로직 처리
        switch action {
        case .move(let x, let y):
            // 이동 처리
            break
        case .attack(let targetId):
            // 공격 처리
            break
        case .useItem(let itemId):
            // 아이템 사용 처리
            break
        case .endTurn:
            // 턴 종료 처리
            break
        }
    }
}
