import SwiftUI
import Observation

/// Self._printChanges()로 뷰 업데이트 추적하기
///
/// 뷰의 body에 이 코드를 추가하면
/// 뷰가 다시 그려질 때마다 콘솔에 정보가 출력됩니다.

@Observable
class DebugCounter {
    var count: Int = 0
    var name: String = "Counter"
}

struct DebugView: View {
    var counter: DebugCounter
    
    var body: some View {
        // 🔍 뷰 업데이트 추적 - 디버깅에 매우 유용!
        let _ = Self._printChanges()
        
        VStack {
            Text("Count: \(counter.count)")
            Text("Name: \(counter.name)")
            
            Button("Increment") {
                counter.count += 1
            }
        }
    }
}

// 콘솔 출력 예시:
// DebugView: @self, @identity, _counter changed.
// DebugView: _counter changed.

// 💡 출력 해석:
// - @self: 뷰 구조체 자체가 새로 생성됨
// - @identity: 뷰의 identity가 변경됨
// - _counter: counter 프로퍼티와 관련된 변경

// ⚠️ 프로덕션에서는 제거하세요!
// #if DEBUG
//     let _ = Self._printChanges()
// #endif
