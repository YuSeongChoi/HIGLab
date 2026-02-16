import Observation
import SwiftUI

/// 계산 프로퍼티는 의존하는 저장 프로퍼티를 통해 관찰됩니다
@Observable
class ShoppingItem {
    var name: String
    var price: Double
    var quantity: Int
    
    // ✅ 계산 프로퍼티 - price 또는 quantity가 바뀌면 자동 업데이트
    var subtotal: Double {
        price * Double(quantity)
    }
    
    // ✅ 여러 프로퍼티에 의존하는 계산 프로퍼티
    var displayText: String {
        "\(name) - \(quantity)개 = \(subtotal)원"
    }
    
    // ✅ Bool 계산 프로퍼티
    var isExpensive: Bool {
        subtotal > 100_000
    }
    
    init(name: String, price: Double, quantity: Int = 1) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}

struct ItemView: View {
    var item: ShoppingItem
    
    var body: some View {
        VStack {
            // subtotal을 읽음 → price나 quantity 변경 시 업데이트
            Text("\(item.subtotal, format: .currency(code: "KRW"))")
            
            if item.isExpensive {
                Text("💸 고가 상품")
                    .foregroundStyle(.red)
            }
        }
    }
}

// 💡 계산 프로퍼티 내부에서 읽는 모든 저장 프로퍼티가 
// 자동으로 의존성으로 등록됩니다!
