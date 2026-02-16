import Foundation
import Observation

/// ⚠️ onChange는 한 번만 호출됩니다!
/// 지속적인 관찰을 위해서는 재등록이 필요합니다.

@Observable
class ContinuousStore {
    var value: Int = 0
}

/// 잘못된 방법 - 첫 번째 변경만 감지
func wrongApproach() {
    let store = ContinuousStore()
    
    withObservationTracking {
        print("값: \(store.value)")
    } onChange: {
        print("변경 감지!") // 한 번만 호출됨
    }
    
    store.value = 1  // "변경 감지!" 출력
    store.value = 2  // ❌ 아무 일도 안 일어남!
    store.value = 3  // ❌ 아무 일도 안 일어남!
}

/// 올바른 방법 - 재귀적 재등록
func continuousObserving() {
    let store = ContinuousStore()
    
    // 재귀 함수로 지속적인 관찰 구현
    func observe() {
        withObservationTracking {
            print("값: \(store.value)")
        } onChange: {
            print("변경 감지!")
            // ✅ 다시 등록하여 다음 변경도 감지
            DispatchQueue.main.async {
                observe()
            }
        }
    }
    
    observe()  // 첫 등록
    
    store.value = 1  // "변경 감지!" + 재등록
    store.value = 2  // "변경 감지!" + 재등록
    store.value = 3  // "변경 감지!" + 재등록
}

/// 종료 조건이 있는 관찰
func observeUntilCondition() {
    let store = ContinuousStore()
    var shouldContinue = true
    
    func observe() {
        guard shouldContinue else { return }
        
        withObservationTracking {
            _ = store.value
        } onChange: {
            if store.value >= 10 {
                print("목표 도달! 관찰 종료")
                shouldContinue = false
            } else {
                DispatchQueue.main.async { observe() }
            }
        }
    }
    
    observe()
}
