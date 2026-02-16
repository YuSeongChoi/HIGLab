import Foundation
import Observation

/// 쇼핑 카트 상태 저장소
/// 앱 전체에서 사용할 메인 상태를 관리합니다.
@Observable
class CartStore {
    /// 카트에 담긴 상품들
    var items: [Product] = []
    
    /// 총 상품 개수
    var totalCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    /// 총 금액
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    /// 카트가 비어있는지
    var isEmpty: Bool {
        items.isEmpty
    }
    
    // MARK: - Actions
    
    /// 상품 추가
    func addProduct(_ product: Product) {
        // 이미 있는 상품이면 수량 증가
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(product)
        }
    }
    
    /// 상품 제거
    func removeProduct(_ product: Product) {
        items.removeAll { $0.id == product.id }
    }
    
    /// 카트 비우기
    func clearCart() {
        items.removeAll()
    }
    
    /// 상품 수량 변경
    func updateQuantity(for product: Product, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
    }
}

// MARK: - Preview Helper

extension CartStore {
    /// 샘플 데이터가 포함된 카트
    static var preview: CartStore {
        let store = CartStore()
        store.items = Array(Product.samples.prefix(3))
        return store
    }
}

#if DEBUG
import SwiftUI

#Preview {
    let store = CartStore.preview
    
    return List {
        ForEach(store.items) { item in
            HStack {
                Text(item.name)
                Spacer()
                Text("×\(item.quantity)")
            }
        }
        
        Section {
            HStack {
                Text("총 금액")
                    .font(.headline)
                Spacer()
                Text("\(store.totalPrice, format: .currency(code: "KRW"))")
                    .font(.headline)
            }
        }
    }
}
#endif
