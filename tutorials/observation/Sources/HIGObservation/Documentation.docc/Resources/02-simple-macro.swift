import Observation

/// @Observable 매크로를 사용한 간단한 클래스
/// Xcode에서 @Observable을 우클릭 → "Expand Macro"로 확장된 코드 확인 가능
@Observable
class Counter {
    var count: Int = 0
    var name: String = "카운터"
    
    func increment() {
        count += 1
    }
}

// 💡 Xcode에서 @Observable 위에서 우클릭 → Expand Macro
// 매크로가 어떤 코드로 확장되는지 직접 확인해보세요!
