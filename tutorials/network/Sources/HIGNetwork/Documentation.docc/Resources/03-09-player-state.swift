import Foundation

// 게임 상태를 나타내는 구조체
struct PlayerState: Codable {
    let playerId: String
    let sequence: UInt32  // 시퀀스 번호로 순서 관리
    let timestamp: TimeInterval
    
    let x: Float
    let y: Float
    let z: Float
    let rotation: Float
    
    let health: Int
    let isMoving: Bool
}

// 수신 측에서 시퀀스 관리
class PlayerStateManager {
    private var lastSequence: [String: UInt32] = [:]
    
    func shouldApply(_ state: PlayerState) -> Bool {
        let lastSeq = lastSequence[state.playerId] ?? 0
        
        // 새로운 시퀀스만 적용
        if state.sequence > lastSeq {
            lastSequence[state.playerId] = state.sequence
            return true
        }
        
        // 오래된 패킷은 무시
        return false
    }
}
