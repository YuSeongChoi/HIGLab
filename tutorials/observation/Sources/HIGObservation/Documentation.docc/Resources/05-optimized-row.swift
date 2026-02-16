import SwiftUI
import Observation

/// 최적화된 상품 행 - 각 영역을 분리

struct OptimizedCartItemRow: View {
    @Bindable var product: Product
    var onDelete: () -> Void
    
    var body: some View {
        let _ = Self._printChanges()
        
        HStack(spacing: 12) {
            // 이미지 영역 - 거의 변하지 않음
            ProductImageView(imageURL: product.imageURL)
            
            // 정보 영역 - 이름, 가격 표시
            ProductInfoView(product: product)
            
            Spacer()
            
            // 수량 조절 영역 - 자주 변함
            QuantitySection(product: product)
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

/// 상품 이미지 뷰 - 독립적
struct ProductImageView: View {
    let imageURL: String?
    
    var body: some View {
        let _ = Self._printChanges()
        
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 60, height: 60)
            .overlay {
                if let imageURL = imageURL {
                    // AsyncImage(url: URL(string: imageURL))
                    Image(systemName: "photo")
                } else {
                    Image(systemName: "bag")
                        .foregroundStyle(.gray)
                }
            }
    }
}

/// 상품 정보 뷰 - 이름, 단가 표시
struct ProductInfoView: View {
    var product: Product
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack(alignment: .leading, spacing: 4) {
            Text(product.name) // name 추적
                .font(.headline)
                .lineLimit(2)
            
            Text(product.price, format: .currency(code: "KRW")) // price 추적
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 소계 표시
            Text("소계: \(product.subtotal, format: .currency(code: "KRW"))") // subtotal 추적
                .font(.caption)
                .foregroundStyle(.blue)
        }
    }
}

/// 수량 조절 섹션 - 자주 변하는 부분
struct QuantitySection: View {
    @Bindable var product: Product
    
    var body: some View {
        let _ = Self._printChanges()
        
        // 수량만 추적
        QuantityStepper(quantity: $product.quantity)
    }
}

#Preview {
    List {
        OptimizedCartItemRow(product: Product.samples[0]) {}
        OptimizedCartItemRow(product: Product.samples[1]) {}
    }
}
