import SwiftUI
import Combine

/// ❌ ObservableObject의 문제점
/// `name`만 바꿔도 `count`를 보여주는 뷰까지 불필요하게 업데이트됩니다.
class OldCartStore: ObservableObject {
    @Published var name: String = "장바구니"
    @Published var count: Int = 0
    @Published var total: Double = 0.0
}

struct OldCartView: View {
    @ObservedObject var store: OldCartStore
    
    var body: some View {
        let _ = Self._printChanges() // 디버깅: 뷰 업데이트 추적
        
        VStack {
            // 이 뷰는 name만 사용하지만...
            Text(store.name)
                .font(.title)
            
            Button("이름 변경") {
                store.name = "My Cart"
                // ⚠️ count를 보여주는 다른 뷰도 함께 업데이트됨!
            }
        }
    }
}

struct OldCountView: View {
    @ObservedObject var store: OldCartStore
    
    var body: some View {
        let _ = Self._printChanges() // 💥 name 변경 시에도 호출됨!
        
        Text("상품 \(store.count)개")
    }
}
