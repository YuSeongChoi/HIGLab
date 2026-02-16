import Foundation
import Observation

// MARK: - CartStore (@Observable)
/// iOS 17+ Observation 프레임워크를 사용한 카트 상태 관리
///
/// ## @Observable vs ObservableObject 비교
///
/// ### 기존 방식 (ObservableObject):
/// ```swift
/// class CartStore: ObservableObject {
///     @Published var items: [CartItem] = []
///     @Published var isLoading = false
/// }
/// ```
/// - View에서 `@ObservedObject` 또는 `@StateObject` 필요
/// - 모든 @Published 변경 시 전체 View 업데이트
///
/// ### 새로운 방식 (@Observable):
/// ```swift
/// @Observable
/// class CartStore {
///     var items: [CartItem] = []
///     var isLoading = false
/// }
/// ```
/// - View에서 별도 프로퍼티 래퍼 불필요 (자동 추적)
/// - 실제 사용하는 프로퍼티만 추적하여 성능 최적화
/// - Macro 기반으로 보일러플레이트 제거

@Observable
class CartStore {
    // MARK: - 상태 (자동 추적됨)
    
    /// 장바구니 아이템 목록
    var items: [CartItem] = []
    
    /// 로딩 상태
    var isLoading = false
    
    /// 결제 완료 상태
    var isCheckoutComplete = false
    
    /// 오류 메시지
    var errorMessage: String?
    
    // MARK: - 계산 속성
    
    /// 카트 내 총 아이템 수량
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    /// 카트 총 금액
    var totalPrice: Int {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    /// 포맷팅된 총 금액
    var formattedTotalPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalPrice)) ?? "\(totalPrice)"
        return "₩\(formatted)"
    }
    
    /// 카트가 비어있는지 여부
    var isEmpty: Bool {
        items.isEmpty
    }
    
    // MARK: - 카트 조작 메서드
    
    /// 상품을 카트에 추가
    /// - Parameters:
    ///   - product: 추가할 상품
    ///   - quantity: 수량 (기본값: 1)
    func addToCart(_ product: Product, quantity: Int = 1) {
        // 이미 카트에 있는 상품이면 수량 증가
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            // 새 상품이면 추가
            let newItem = CartItem(product: product, quantity: quantity)
            items.append(newItem)
        }
    }
    
    /// 카트에서 상품 제거
    /// - Parameter product: 제거할 상품
    func removeFromCart(_ product: Product) {
        items.removeAll { $0.product.id == product.id }
    }
    
    /// 특정 아이템의 수량 변경
    /// - Parameters:
    ///   - item: 대상 카트 아이템
    ///   - newQuantity: 새 수량 (0 이하면 제거)
    func updateQuantity(for item: CartItem, to newQuantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if newQuantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = newQuantity
        }
    }
    
    /// 수량 1 증가
    func incrementQuantity(for item: CartItem) {
        updateQuantity(for: item, to: item.quantity + 1)
    }
    
    /// 수량 1 감소 (1개면 제거)
    func decrementQuantity(for item: CartItem) {
        updateQuantity(for: item, to: item.quantity - 1)
    }
    
    /// 카트 비우기
    func clearCart() {
        items.removeAll()
        isCheckoutComplete = false
        errorMessage = nil
    }
    
    /// 특정 상품이 카트에 있는지 확인
    func contains(_ product: Product) -> Bool {
        items.contains { $0.product.id == product.id }
    }
    
    /// 특정 상품의 카트 내 수량
    func quantity(of product: Product) -> Int {
        items.first { $0.product.id == product.id }?.quantity ?? 0
    }
    
    // MARK: - 결제 시뮬레이션
    
    /// 결제 처리 (Mock)
    @MainActor
    func checkout() async {
        guard !isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        // 네트워크 요청 시뮬레이션 (2초)
        try? await Task.sleep(for: .seconds(2))
        
        // 90% 확률로 성공
        if Double.random(in: 0...1) > 0.1 {
            items.removeAll()
            isCheckoutComplete = true
        } else {
            errorMessage = "결제 처리 중 오류가 발생했습니다. 다시 시도해주세요."
        }
        
        isLoading = false
    }
    
    /// 결제 완료 상태 초기화
    func resetCheckout() {
        isCheckoutComplete = false
        errorMessage = nil
    }
}

// MARK: - Preview Support

extension CartStore {
    /// 미리보기용 샘플 데이터가 채워진 Store
    static var preview: CartStore {
        let store = CartStore()
        store.items = CartItem.samples
        return store
    }
    
    /// 비어있는 Store
    static var empty: CartStore {
        CartStore()
    }
}
