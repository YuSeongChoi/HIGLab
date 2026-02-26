import Foundation
import SwiftData

@Model
final class Order {
    var orderId: String
    var items: [OrderItem]
    var totalAmount: Decimal
    var status: String
    var paymentMethod: String
    var orderedAt: Date
    
    init(items: [OrderItem], totalAmount: Decimal, paymentMethod: String) {
        self.orderId = UUID().uuidString
        self.items = items
        self.totalAmount = totalAmount
        self.status = "completed"
        self.paymentMethod = paymentMethod
        self.orderedAt = Date()
    }
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: totalAmount as NSDecimalNumber) ?? "₩0"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: orderedAt)
    }
}

struct OrderItem: Codable, Hashable {
    let productName: String
    let quantity: Int
    let price: Decimal
}
