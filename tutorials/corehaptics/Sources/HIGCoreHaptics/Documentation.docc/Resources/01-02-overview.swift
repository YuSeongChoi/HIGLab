import CoreHaptics

// MARK: - CoreHaptics 핵심 구성요소

/*
 1. CHHapticEngine
    - 햅틱 재생을 관리하는 핵심 엔진
    - 생성 → 시작 → 재생 → 정지 라이프사이클
 
 2. CHHapticPattern
    - 햅틱 이벤트들의 시퀀스
    - 여러 이벤트를 조합하여 복잡한 패턴 생성
 
 3. CHHapticEvent
    - 개별 햅틱 이벤트
    - Transient (순간) 또는 Continuous (지속)
 
 4. CHHapticPatternPlayer
    - 패턴을 실제로 재생하는 플레이어
    - 시작, 정지, 동적 파라미터 조절
 */

// 기본 사용 흐름
class HapticManager {
    var engine: CHHapticEngine?
    
    func setup() throws {
        // 1. 엔진 생성
        engine = try CHHapticEngine()
        
        // 2. 엔진 시작
        try engine?.start()
    }
    
    func playSimpleHaptic() throws {
        // 3. 이벤트 생성
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [],
            relativeTime: 0
        )
        
        // 4. 패턴 생성
        let pattern = try CHHapticPattern(events: [event], parameters: [])
        
        // 5. 플레이어 생성 및 재생
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: CHHapticTimeImmediate)
    }
}
