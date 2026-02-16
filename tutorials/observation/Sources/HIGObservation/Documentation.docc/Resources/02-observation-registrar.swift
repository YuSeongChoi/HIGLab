import Observation

/// ObservationRegistrar의 역할 이해하기
/// 
/// ObservationRegistrar는 두 가지 핵심 메서드를 제공합니다:
/// 1. access(_:keyPath:) - 프로퍼티 읽기 추적
/// 2. withMutation(of:keyPath:_:) - 프로퍼티 변경 추적

@Observable
class ExampleStore {
    var items: [String] = []  // 저장 프로퍼티
    
    // 위 프로퍼티는 내부적으로 이렇게 동작합니다:
    //
    // var items: [String] {
    //     get {
    //         // 🔹 "누군가 items를 읽었다" 기록
    //         _$observationRegistrar.access(self, keyPath: \.items)
    //         return _items
    //     }
    //     set {
    //         // 🔹 "items가 바뀔 것이다" 알림 → 관찰자에게 통지
    //         _$observationRegistrar.withMutation(of: self, keyPath: \.items) {
    //             _items = newValue
    //         }
    //     }
    // }
}

// 💡 SwiftUI는 body 실행 중 access()가 호출된 프로퍼티를 기록하고,
// 그 프로퍼티의 withMutation()이 호출되면 뷰를 업데이트합니다.

// 📝 동작 흐름:
// 1. SwiftUI가 뷰의 body 실행
// 2. body에서 store.items 접근 → access() 호출
// 3. SwiftUI가 "이 뷰는 items를 관찰한다" 기록
// 4. 나중에 items 변경 → withMutation() 호출
// 5. SwiftUI가 해당 뷰만 다시 그림
