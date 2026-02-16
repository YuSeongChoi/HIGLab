import SwiftUI
import Observation

/// 업데이트된 장바구니 뷰
/// CartItemRow를 사용하고 총 금액이 자동으로 업데이트됩니다.
struct UpdatedCartView: View {
    var store: CartStore
    
    var body: some View {
        Group {
            if store.isEmpty {
                // 빈 상태
                ContentUnavailableView(
                    "장바구니가 비어있어요",
                    systemImage: "cart",
                    description: Text("상품을 담아보세요!")
                )
            } else {
                List {
                    // 상품 목록
                    Section {
                        ForEach(store.items) { product in
                            // @Bindable 덕분에 수량 편집 가능!
                            EnhancedCartItemRow(product: product) {
                                store.removeProduct(product)
                            }
                        }
                    }
                    
                    // 주문 요약
                    Section("주문 요약") {
                        SummaryRow(title: "상품 수", value: "\(store.totalCount)개")
                        
                        SummaryRow(
                            title: "총 금액",
                            value: store.totalPrice.formatted(.currency(code: "KRW")),
                            isHighlighted: true
                        )
                    }
                    
                    // 주문 버튼
                    Section {
                        Button {
                            checkout()
                        } label: {
                            Text("주문하기")
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .navigationTitle("장바구니")
        .toolbar {
            if !store.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("비우기", role: .destructive) {
                        store.clearCart()
                    }
                }
            }
        }
    }
    
    private func checkout() {
        // TODO: 결제 로직
        print("주문 금액: \(store.totalPrice)")
    }
}

/// 요약 행 뷰
struct SummaryRow: View {
    let title: String
    let value: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(isHighlighted ? .primary : .secondary)
            Spacer()
            Text(value)
                .fontWeight(isHighlighted ? .bold : .regular)
        }
        .font(isHighlighted ? .headline : .body)
    }
}

#Preview {
    NavigationStack {
        UpdatedCartView(store: .preview)
    }
}
