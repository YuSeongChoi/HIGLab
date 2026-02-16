import SwiftUI
import Observation

/// 상품 목록 뷰
struct ProductListView: View {
    var store: CartStore
    
    // 표시할 샘플 상품들
    let products = Product.samples
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 16
            ) {
                ForEach(products) { product in
                    ProductCard(product: product) {
                        store.addProduct(product)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("상품 목록")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // 카트 아이콘 + 뱃지
                CartBadgeButton(count: store.totalCount)
            }
        }
    }
}

/// 카트 뱃지 버튼
struct CartBadgeButton: View {
    var count: Int
    
    var body: some View {
        Button {
            // 카트 화면으로 이동 (나중에 구현)
        } label: {
            Image(systemName: "cart.fill")
                .overlay(alignment: .topTrailing) {
                    if count > 0 {
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        ProductListView(store: CartStore())
    }
}
