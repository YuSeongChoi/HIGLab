import SwiftUI
import Observation

/// 최적화된 장바구니 뷰
/// 각 영역이 독립적으로 업데이트됩니다.

struct OptimizedCartView: View {
    var store: CartStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        Group {
            if store.isEmpty {
                EmptyCartView()
            } else {
                CartContentView(store: store)
            }
        }
        .navigationTitle("장바구니")
        .toolbar {
            CartToolbar(store: store)
        }
    }
}

/// 빈 카트 뷰 - 정적
struct EmptyCartView: View {
    var body: some View {
        ContentUnavailableView(
            "장바구니가 비어있어요",
            systemImage: "cart",
            description: Text("상품을 담아보세요!")
        )
    }
}

/// 카트 내용 뷰 - 상품 목록 + 요약
struct CartContentView: View {
    var store: CartStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack(spacing: 0) {
            // 상품 목록 영역
            CartItemsListView(store: store)
            
            // 요약 영역 - 별도 컴포넌트
            CartSummaryView(store: store)
                .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// 상품 목록 뷰
struct CartItemsListView: View {
    var store: CartStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        List {
            ForEach(store.items) { product in
                OptimizedCartItemRow(product: product) {
                    withAnimation {
                        store.removeProduct(product)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

/// 툴바 - 비우기 버튼
struct CartToolbar: ToolbarContent {
    var store: CartStore
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if !store.isEmpty {
                Button("비우기", role: .destructive) {
                    withAnimation {
                        store.clearCart()
                    }
                }
            }
        }
    }
}

#Preview("Empty") {
    NavigationStack {
        OptimizedCartView(store: CartStore())
    }
}

#Preview("With Items") {
    NavigationStack {
        OptimizedCartView(store: .preview)
    }
}
