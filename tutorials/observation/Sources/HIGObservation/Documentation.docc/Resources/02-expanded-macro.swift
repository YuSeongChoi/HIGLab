import Observation

/// @Observable 매크로가 확장된 모습 (개념적 설명)
/// 실제 코드는 더 복잡하지만, 핵심 구조는 이렇습니다.
class Counter: Observable {
    
    // 🔹 관찰 인프라 - 매크로가 자동 생성
    @ObservationIgnored
    private let _$observationRegistrar = ObservationRegistrar()
    
    // 🔹 원래 저장 프로퍼티는 언더스코어 버전으로 변환
    @ObservationIgnored
    private var _count: Int = 0
    
    @ObservationIgnored
    private var _name: String = "카운터"
    
    // 🔹 외부에 노출되는 프로퍼티 - 접근/변경 추적 코드 포함
    var count: Int {
        get {
            // 읽기 추적
            _$observationRegistrar.access(self, keyPath: \.count)
            return _count
        }
        set {
            // 변경 추적 (willSet + didSet)
            _$observationRegistrar.withMutation(of: self, keyPath: \.count) {
                _count = newValue
            }
        }
    }
    
    var name: String {
        get {
            _$observationRegistrar.access(self, keyPath: \.name)
            return _name
        }
        set {
            _$observationRegistrar.withMutation(of: self, keyPath: \.name) {
                _name = newValue
            }
        }
    }
    
    func increment() {
        count += 1
    }
}

// 💡 핵심 포인트:
// 1. ObservationRegistrar가 모든 추적을 담당
// 2. access(): "이 프로퍼티를 읽었다" 기록
// 3. withMutation(): "이 프로퍼티가 바뀔 것이다" 알림
