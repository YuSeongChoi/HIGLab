import SwiftUI
import Observation

/// 재사용 가능한 수량 조절 컴포넌트
struct QuantityStepper: View {
    // ✅ Binding을 사용하면 @Bindable 객체의 프로퍼티를 직접 받을 수 있음
    @Binding var quantity: Int
    var minValue: Int = 1
    var maxValue: Int = 99
    
    var body: some View {
        HStack(spacing: 8) {
            Button {
                if quantity > minValue {
                    quantity -= 1
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(quantity > minValue ? .blue : .gray)
            }
            .disabled(quantity <= minValue)
            
            Text("\(quantity)")
                .font(.headline)
                .frame(minWidth: 36)
                .padding(.horizontal, 4)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Button {
                if quantity < maxValue {
                    quantity += 1
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(quantity < maxValue ? .blue : .gray)
            }
            .disabled(quantity >= maxValue)
        }
        .buttonStyle(.plain)
    }
}

/// CartItemRow에서 QuantityStepper 사용
struct EnhancedCartItemRow: View {
    @Bindable var product: Product
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 상품 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                
                Text(product.subtotal, format: .currency(code: "KRW"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // ✅ $product.quantity로 Binding 전달!
            QuantityStepper(quantity: $product.quantity)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

#Preview {
    @Previewable @State var product = Product.samples[0]
    
    List {
        EnhancedCartItemRow(product: product) {
            print("Deleted")
        }
    }
}
