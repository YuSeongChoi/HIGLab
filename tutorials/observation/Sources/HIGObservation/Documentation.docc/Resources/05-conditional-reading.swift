import SwiftUI
import Observation

/// 조건부 읽기를 활용한 최적화
/// 프로퍼티를 읽지 않으면 추적되지 않습니다!

@Observable
class ConditionalStore {
    var showDetails: Bool = false
    var details: String = "상세 정보..."
    var summary: String = "요약"
}

struct SmartView: View {
    var store: ConditionalStore
    
    var body: some View {
        VStack {
            // summary는 항상 읽음 → 항상 추적
            Text(store.summary)
            
            if store.showDetails {
                // details는 showDetails가 true일 때만 읽음
                // → showDetails가 false면 details 변경에 반응 안 함!
                Text(store.details)
            }
            
            Toggle("상세 보기", isOn: Binding(
                get: { store.showDetails },
                set: { store.showDetails = $0 }
            ))
        }
    }
}

// 💡 동작 분석:
//
// showDetails = false 상태:
// - summary 추적 ✅
// - showDetails 추적 ✅
// - details 추적 ❌ (읽지 않음!)
//
// store.details = "새 정보" 실행:
// → 뷰 업데이트 없음! (details를 추적하지 않으므로)
//
// showDetails = true 상태:
// - summary 추적 ✅
// - showDetails 추적 ✅
// - details 추적 ✅
//
// store.details = "새 정보" 실행:
// → 뷰 업데이트됨!

// ⚠️ 주의: 이 최적화는 자동으로 적용됩니다.
// 별도의 코드 수정 없이도 조건부 렌더링만으로 최적화됩니다.
