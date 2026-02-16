import SwiftUI
import Observation

/// 장바구니 요약 뷰 - 별도 컴포넌트로 분리
/// 총 금액과 상품 수만 추적하여 불필요한 업데이트 방지

struct CartSummaryView: View {
    var store: CartStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack(spacing: 12) {
            // 상품 수
            HStack {
                Text("상품 수")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(store.totalCount)개") // totalCount만 추적
            }
            
            // 총 금액
            HStack {
                Text("총 금액")
                    .font(.headline)
                Spacer()
                Text(store.totalPrice, format: .currency(code: "KRW")) // totalPrice만 추적
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
            
            // 결제 버튼
            CheckoutButton(store: store)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// 결제 버튼 - 독립적인 컴포넌트
struct CheckoutButton: View {
    var store: CartStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        Button {
            checkout()
        } label: {
            HStack {
                Text("결제하기")
                    .fontWeight(.semibold)
                
                if store.totalCount > 0 { // 최소한의 상태만 접근
                    Text("(\(store.totalCount)개)")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .disabled(store.isEmpty) // isEmpty만 추가 추적
    }
    
    private func checkout() {
        // 결제 로직
        print("결제 시작: \(store.totalPrice)원")
    }
}

#Preview {
    VStack {
        Spacer()
        CartSummaryView(store: .preview)
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}
