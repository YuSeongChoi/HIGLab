import SwiftUI
import Observation

/// 장바구니 아이템 행 뷰
/// Product를 @Bindable로 받아서 수량을 직접 편집합니다.
struct CartItemRow: View {
    @Bindable var product: Product
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 상품 이미지
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "bag")
                        .foregroundStyle(.gray)
                }
            
            // 상품 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(product.price, format: .currency(code: "KRW"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 수량 조절 (다음 스텝에서 QuantityStepper로 교체)
            HStack(spacing: 4) {
                Button {
                    if product.quantity > 1 {
                        product.quantity -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.plain)
                
                Text("\(product.quantity)")
                    .frame(minWidth: 30)
                    .font(.headline)
                
                Button {
                    product.quantity += 1
                } label: {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

#Preview {
    List {
        CartItemRow(product: Product.samples[0]) {
            print("Deleted")
        }
    }
}
