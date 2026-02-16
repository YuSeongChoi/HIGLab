import SwiftUI
import Observation
// ✅ Combine import 불필요!

/// Observation은 순수 Swift로 구현되었습니다.
/// Combine의 Publisher/Subscriber 개념 없이도 상태 관찰이 가능합니다.
@Observable
class SimpleStore {
    var items: [String] = []
    var isLoading: Bool = false
    
    func addItem(_ item: String) {
        // 그냥 값을 바꾸면 됩니다. 자동으로 관찰자에게 알림!
        items.append(item)
    }
}

/// SwiftUI 외부에서도 관찰 가능
func observeChanges() {
    let store = SimpleStore()
    
    // withObservationTracking으로 변화 감지
    withObservationTracking {
        // 이 클로저에서 읽은 프로퍼티들을 추적
        print("현재 아이템: \(store.items)")
    } onChange: {
        // 추적 중인 프로퍼티가 변하면 호출
        print("아이템이 변경됨!")
    }
}

// 💡 Combine이 필요한 경우 (debounce, throttle 등)?
// Combine과 함께 사용할 수도 있습니다.
// 하지만 대부분의 UI 상태 관리는 Observation만으로 충분합니다.

// 📊 성능 비교:
// - ObservableObject: Combine 런타임 오버헤드
// - @Observable: 컴파일 타임 코드 생성, 런타임 비용 최소화
