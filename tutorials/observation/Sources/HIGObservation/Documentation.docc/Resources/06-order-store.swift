import SwiftUI
import Observation

// MARK: - CartFlow: 주문 정보 관리
// ShippingAddress를 포함하는 중첩 Observable

@Observable
class OrderStore {
    // 중첩된 Observable 객체
    var shippingAddress: ShippingAddress
    
    // 주문 관련 상태
    var paymentMethod: PaymentMethod
    var orderNote: String
    var usePoints: Int
    var agreedToTerms: Bool
    
    init(
        shippingAddress: ShippingAddress = ShippingAddress(),
        paymentMethod: PaymentMethod = .card,
        orderNote: String = "",
        usePoints: Int = 0,
        agreedToTerms: Bool = false
    ) {
        self.shippingAddress = shippingAddress
        self.paymentMethod = paymentMethod
        self.orderNote = orderNote
        self.usePoints = usePoints
        self.agreedToTerms = agreedToTerms
    }
    
    // 주문 가능 여부
    var canPlaceOrder: Bool {
        shippingAddress.isValid && agreedToTerms
    }
    
    // 배송지 변경
    func updateShippingAddress(_ address: ShippingAddress) {
        shippingAddress = address
    }
    
    // 저장된 배송지 목록에서 선택
    func selectSavedAddress(_ address: ShippingAddress) {
        // 새 객체로 복사하여 할당
        shippingAddress = address.copy()
    }
}

// MARK: - 결제 수단

enum PaymentMethod: String, CaseIterable {
    case card = "신용카드"
    case bank = "계좌이체"
    case phone = "휴대폰결제"
    case kakao = "카카오페이"
    case naver = "네이버페이"
    
    var icon: String {
        switch self {
        case .card: return "creditcard"
        case .bank: return "building.columns"
        case .phone: return "iphone"
        case .kakao: return "message"
        case .naver: return "n.square"
        }
    }
}

// MARK: - 샘플 데이터

extension OrderStore {
    static let sample = OrderStore(
        shippingAddress: .sample,
        paymentMethod: .card
    )
}
