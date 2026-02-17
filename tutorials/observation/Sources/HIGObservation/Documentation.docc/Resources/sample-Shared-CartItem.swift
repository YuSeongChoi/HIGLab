import Foundation

// MARK: - 카트 아이템 모델
/// 장바구니에 담긴 상품과 수량을 나타내는 모델

struct CartItem: Identifiable, Equatable {
    let id: UUID
    let product: Product
    var quantity: Int
    
    init(id: UUID = UUID(), product: Product, quantity: Int = 1) {
        self.id = id
        self.product = product
        self.quantity = max(1, quantity) // 최소 1개
    }
    
    // MARK: - 계산 속성
    
    /// 해당 아이템의 총 금액 (상품 가격 × 수량)
    var totalPrice: Int {
        product.price * quantity
    }
    
    /// 포맷팅된 총 금액 문자열
    var formattedTotalPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalPrice)) ?? "\(totalPrice)"
        return "₩\(formatted)"
    }
    
    // MARK: - Equatable
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id && lhs.quantity == rhs.quantity
    }
}

// MARK: - Preview / Mock Data

extension CartItem {
    static let preview = CartItem(
        product: .preview,
        quantity: 2
    )
    
    static let samples: [CartItem] = [
        CartItem(product: Product.samples[0], quantity: 1),
        CartItem(product: Product.samples[3], quantity: 2),
        CartItem(product: Product.samples[5], quantity: 3),
    ]
}
