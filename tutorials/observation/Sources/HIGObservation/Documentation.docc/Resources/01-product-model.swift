import Foundation
import Observation

/// 상품 모델
/// @Observable을 사용하면 SwiftUI가 자동으로 변화를 감지합니다.
@Observable
class Product: Identifiable {
    let id: UUID
    var name: String
    var price: Double
    var quantity: Int
    var imageURL: String?
    
    /// 상품의 소계 (가격 × 수량)
    var subtotal: Double {
        price * Double(quantity)
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        quantity: Int = 1,
        imageURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.imageURL = imageURL
    }
}

// MARK: - 샘플 데이터

extension Product {
    static let samples: [Product] = [
        Product(name: "맥북 프로 14인치", price: 2_390_000),
        Product(name: "아이폰 15 Pro", price: 1_550_000),
        Product(name: "에어팟 프로 2", price: 359_000),
        Product(name: "애플워치 시리즈 9", price: 599_000),
        Product(name: "아이패드 프로 12.9", price: 1_499_000),
    ]
}

#if DEBUG
import SwiftUI

#Preview {
    List(Product.samples) { product in
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.headline)
            Text("\(product.price, format: .currency(code: "KRW"))")
                .foregroundStyle(.secondary)
        }
    }
}
#endif
