import Foundation
import Observation

/// withObservationTracking 기본 사용법
///
/// SwiftUI 없이도 @Observable 객체의 변화를 감지할 수 있습니다.

@Observable
class DataStore {
    var items: [String] = []
    var isLoading: Bool = false
}

func demonstrateTracking() {
    let store = DataStore()
    
    // 기본 구조: apply + onChange
    withObservationTracking {
        // 🔍 apply 클로저: 여기서 접근한 프로퍼티가 추적됨
        print("현재 아이템 수: \(store.items.count)")
        print("로딩 중: \(store.isLoading)")
        // items와 isLoading 둘 다 추적됨
        
    } onChange: {
        // 🔔 onChange 클로저: 추적 중인 프로퍼티가 변하면 호출
        // ⚠️ 메인 스레드에서 호출되지 않을 수 있음!
        print("데이터가 변경됨!")
    }
    
    // onChange는 여기서 호출됩니다
    store.items.append("새 아이템")
}

// 출력:
// 현재 아이템 수: 0
// 로딩 중: false
// 데이터가 변경됨!

// 💡 핵심 포인트:
// 1. apply에서 접근한 프로퍼티만 추적됨
// 2. 추적 중인 프로퍼티 중 하나라도 변하면 onChange 호출
// 3. onChange는 한 번만 호출됨 (일회성!)
