import SwiftUI
import Observation

/// ✅ @Observable로 해결!
/// 뷰는 실제로 "읽은" 프로퍼티만 관찰합니다.
@Observable
class CartStore {
    var name: String = "장바구니"
    var count: Int = 0
    var total: Double = 0.0
}

struct CartNameView: View {
    var store: CartStore // @ObservedObject 불필요!
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack {
            // 이 뷰는 name만 읽습니다
            Text(store.name)
                .font(.title)
            
            Button("이름 변경") {
                store.name = "My Cart"
                // ✅ count를 보여주는 뷰는 업데이트되지 않음!
            }
        }
    }
}

struct CartCountView: View {
    var store: CartStore
    
    var body: some View {
        let _ = Self._printChanges() // ✅ name 변경 시 호출 안 됨!
        
        // 이 뷰는 count만 읽습니다
        Text("상품 \(store.count)개")
    }
}

// 💡 핵심: 뷰가 body에서 접근한 프로퍼티만 추적됩니다.
// 이것이 "세밀한 관찰(Granular Observation)"입니다!
