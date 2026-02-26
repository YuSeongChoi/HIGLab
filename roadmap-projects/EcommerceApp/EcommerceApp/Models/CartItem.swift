import Foundation
import SwiftData

@Model
final class CartItem {
    var productId: String
    var productName: String
    var price: Decimal
    var quantity: Int
    var addedAt: Date
    
    init(product: Product, quantity: Int = 1) {
        self.productId = product.id
        self.productName = product.name
        self.price = product.price
        self.quantity = quantity
        self.addedAt = Date()
    }
    
    var subtotal: Decimal {
        price * Decimal(quantity)
    }
    
    var formattedSubtotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: subtotal as NSDecimalNumber) ?? "₩0"
    }
}
