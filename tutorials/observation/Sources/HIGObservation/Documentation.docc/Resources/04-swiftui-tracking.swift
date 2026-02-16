import SwiftUI
import Observation

/// SwiftUI가 body 실행 시 프로퍼티를 추적하는 방법

@Observable
class Counter {
    var count: Int = 0
    var name: String = "Counter"
}

struct CounterView: View {
    var counter: Counter
    
    // SwiftUI가 body를 실행할 때 내부적으로 이런 일이 일어납니다:
    //
    // 1. withObservationTracking 시작
    // 2. body 실행하며 접근한 프로퍼티 기록
    // 3. 추적된 프로퍼티가 변하면 body 재실행
    
    var body: some View {
        // 이 시점에 counter.count 접근 → 추적 대상 등록
        Text("Count: \(counter.count)")
    }
    
    // 개념적으로 SwiftUI는 이렇게 동작합니다:
    //
    // func renderView() {
    //     withObservationTracking {
    //         let content = body  // body 실행, 접근한 프로퍼티 추적
    //         render(content)
    //     } onChange: {
    //         // 추적 중인 프로퍼티가 변하면
    //         scheduleViewUpdate()  // 뷰 업데이트 예약
    //     }
    // }
}

/// 여러 프로퍼티에 접근하는 경우
struct MultiPropertyView: View {
    var counter: Counter
    
    var body: some View {
        VStack {
            // count 접근 → count 추적
            Text("Count: \(counter.count)")
            
            // name 접근 → name도 추적
            Text("Name: \(counter.name)")
        }
        // 💡 count 또는 name 중 하나라도 바뀌면 뷰 업데이트
    }
}

/// 조건부 접근
struct ConditionalView: View {
    var counter: Counter
    var showName: Bool
    
    var body: some View {
        VStack {
            Text("Count: \(counter.count)") // 항상 추적
            
            if showName {
                Text("Name: \(counter.name)") // showName이 true일 때만 추적
            }
        }
        // 💡 showName이 false면 name 변경에 반응하지 않음!
    }
}
