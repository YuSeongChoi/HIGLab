import Foundation
import Observation

/// withMutation의 실행 흐름
///
/// ObservationRegistrar.withMutation은 다음 순서로 동작합니다:
/// 1. willSet 알림 (관찰자에게 "곧 바뀐다" 통지)
/// 2. 실제 값 변경
/// 3. didSet 알림 (변경 완료 통지)

@Observable
class FlowDemo {
    var value: Int = 0
}

// 개념적으로 이렇게 동작합니다:
extension ObservationRegistrar {
    func withMutationExample<T, V>(
        of object: T,
        keyPath: KeyPath<T, V>,
        _ mutation: () -> Void
    ) {
        // 1️⃣ willSet - "value가 바뀔 것이다"
        willSet(object, keyPath: keyPath)
        
        // 2️⃣ 실제 값 변경
        mutation()
        
        // 3️⃣ didSet - "value가 바뀌었다"
        didSet(object, keyPath: keyPath)
    }
    
    // 실제 ObservationRegistrar의 메서드들
    func willSet<T, V>(_ object: T, keyPath: KeyPath<T, V>) {
        // 추적 중인 관찰자들에게 알림
        print("🔔 \(keyPath) will change")
    }
    
    func didSet<T, V>(_ object: T, keyPath: KeyPath<T, V>) {
        // 변경 완료 알림
        print("✅ \(keyPath) did change")
    }
}

// 사용 예시:
func demonstrateFlow() {
    let demo = FlowDemo()
    
    print("변경 전: \(demo.value)")
    demo.value = 42  // willSet → 값 변경 → didSet
    print("변경 후: \(demo.value)")
}

// 출력:
// 변경 전: 0
// 🔔 \value will change
// ✅ \value did change
// 변경 후: 42
