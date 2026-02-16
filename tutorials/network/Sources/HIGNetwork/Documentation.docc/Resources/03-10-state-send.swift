import Network
import Foundation

class GameClient {
    private var connection: NWConnection?
    private var sequenceNumber: UInt32 = 0
    private let playerId = UUID().uuidString
    
    func sendPlayerState(x: Float, y: Float, z: Float, rotation: Float) {
        sequenceNumber += 1
        
        let state = PlayerState(
            playerId: playerId,
            sequence: sequenceNumber,
            timestamp: Date().timeIntervalSince1970,
            x: x,
            y: y,
            z: z,
            rotation: rotation,
            health: 100,
            isMoving: true
        )
        
        // Codable로 직렬화
        guard let data = try? JSONEncoder().encode(state) else { return }
        
        // 빠른 전송, 결과 무시
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .idempotent
        )
    }
    
    // 60fps로 위치 업데이트
    func startPositionUpdates() {
        Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            // 현재 위치 가져와서 전송
            self?.sendCurrentPosition()
        }
    }
    
    private func sendCurrentPosition() {
        // 실제로는 게임 엔진에서 위치를 가져옴
    }
}
