import SwiftUI
import Observation

/// 상품 카드 뷰
/// @Observable 객체를 그냥 프로퍼티로 받습니다 - 특별한 wrapper 불필요!
struct ProductCard: View {
    var product: Product
    var onAddToCart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상품 이미지 플레이스홀더
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 120)
                .overlay {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                }
            
            // 상품 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.price, format: .currency(code: "KRW"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 장바구니 담기 버튼
            Button(action: onAddToCart) {
                Label("담기", systemImage: "cart.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

#Preview {
    ProductCard(product: Product.samples[0]) {
        print("Added to cart!")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
