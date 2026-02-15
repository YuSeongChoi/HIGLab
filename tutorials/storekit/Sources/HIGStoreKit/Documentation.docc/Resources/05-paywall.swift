import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject var store = StoreManager()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // 헤더: 가치 전달
            VStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.yellow)
                
                Text("프리미엄으로 업그레이드")
                    .font(.title2.bold())
                
                Text("모든 기능을 제한 없이 사용하세요")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 32)
            
            // 기능 목록
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "checkmark.circle.fill", text: "무제한 저장")
                FeatureRow(icon: "checkmark.circle.fill", text: "광고 제거")
                FeatureRow(icon: "checkmark.circle.fill", text: "클라우드 동기화")
                FeatureRow(icon: "checkmark.circle.fill", text: "프리미엄 테마")
            }
            .padding()
            
            Spacer()
            
            // 가격 선택
            ForEach(store.products) { product in
                PricingCard(product: product) {
                    Task {
                        try? await store.purchase(product)
                    }
                }
            }
            
            // 복원 버튼 (HIG 필수)
            Button("구매 복원") {
                Task { await store.updatePurchasedProducts() }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // 이용약관
            Text("구독은 자동 갱신됩니다. 언제든 취소 가능합니다.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .task { await store.loadProducts() }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
        }
    }
}
