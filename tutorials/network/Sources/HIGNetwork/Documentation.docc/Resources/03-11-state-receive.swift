import Network
import Foundation

class GameClient {
    private var connection: NWConnection?
    private let stateManager = PlayerStateManager()
    
    var onPlayerStateUpdate: ((PlayerState) -> Void)?
    
    func startReceiving() {
        receiveLoop()
    }
    
    private func receiveLoop() {
        connection?.receiveMessage { [weak self] data, _, _, error in
            guard let self = self, error == nil, let data = data else {
                self?.receiveLoop()
                return
            }
            
            // JSON 디코딩
            guard let state = try? JSONDecoder().decode(PlayerState.self, from: data) else {
                self.receiveLoop()
                return
            }
            
            // 시퀀스 번호 확인 - 오래된 패킷 무시
            if self.stateManager.shouldApply(state) {
                DispatchQueue.main.async {
                    self.onPlayerStateUpdate?(state)
                }
            } else {
                print("오래된 패킷 무시: seq=\(state.sequence)")
            }
            
            self.receiveLoop()
        }
    }
}

// 사용 예시
let client = GameClient()
client.onPlayerStateUpdate = { state in
    // 다른 플레이어 위치 업데이트
    updateOtherPlayer(
        id: state.playerId,
        position: (state.x, state.y, state.z),
        rotation: state.rotation
    )
}

func updateOtherPlayer(id: String, position: (Float, Float, Float), rotation: Float) {
    // 게임 렌더링 업데이트
}
