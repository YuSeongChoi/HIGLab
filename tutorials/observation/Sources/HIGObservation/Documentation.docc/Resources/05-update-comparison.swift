import SwiftUI
import Combine
import Observation

/// ObservableObject vs @Observable 업데이트 비교

// MARK: - ObservableObject (기존 방식)

class OldStore: ObservableObject {
    @Published var name: String = "이름"
    @Published var count: Int = 0
    @Published var isActive: Bool = false
}

struct OldNameView: View {
    @ObservedObject var store: OldStore
    
    var body: some View {
        let _ = Self._printChanges()
        Text(store.name)
        // ❌ count가 바뀌어도 이 뷰가 업데이트됨!
    }
}

struct OldCountView: View {
    @ObservedObject var store: OldStore
    
    var body: some View {
        let _ = Self._printChanges()
        Text("\(store.count)")
        // ❌ name이 바뀌어도 이 뷰가 업데이트됨!
    }
}

// MARK: - @Observable (새로운 방식)

@Observable
class NewStore {
    var name: String = "이름"
    var count: Int = 0
    var isActive: Bool = false
}

struct NewNameView: View {
    var store: NewStore
    
    var body: some View {
        let _ = Self._printChanges()
        Text(store.name)
        // ✅ name이 바뀔 때만 업데이트!
    }
}

struct NewCountView: View {
    var store: NewStore
    
    var body: some View {
        let _ = Self._printChanges()
        Text("\(store.count)")
        // ✅ count가 바뀔 때만 업데이트!
    }
}

// 💡 테스트 시나리오:
// store.name = "새 이름" 실행 시
//
// ObservableObject:
// - OldNameView: _store changed.
// - OldCountView: _store changed.  ← 불필요한 업데이트!
//
// @Observable:
// - NewNameView: _store changed.
// - NewCountView: (출력 없음)  ← 최적화됨!
