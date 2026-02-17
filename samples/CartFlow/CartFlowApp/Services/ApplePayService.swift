import Foundation
import PassKit
import Observation

// MARK: - Apple Pay 서비스
/// Apple Pay 결제를 처리하는 핵심 서비스 클래스
///
/// ## 개요
/// `ApplePayService`는 PassKit 프레임워크를 활용하여
/// Apple Pay 결제 프로세스 전체를 관리합니다.
///
/// ## 주요 기능
/// - 결제 가능 여부 확인
/// - 결제 요청 생성 및 표시
/// - 배송 정보 업데이트 처리
/// - 결제 승인 및 완료 처리
///
/// ## 사용 예시
/// ```swift
/// let service = ApplePayService()
///
/// // 결제 가능 여부 확인
/// guard service.canMakePayments else { return }
///
/// // 결제 실행
/// do {
///     let result = try await service.processPayment(
///         for: cartItems,
///         shippingMethod: .express
///     )
///     print("결제 성공: \(result.transactionId)")
/// } catch let error as PaymentError {
///     print("결제 실패: \(error.localizedDescription)")
/// }
/// ```
///
/// ## 아키텍처
/// ```
/// ┌─────────────────────────────────────────────────┐
/// │                 ApplePayService                  │
/// ├─────────────────────────────────────────────────┤
/// │  ┌──────────────┐    ┌───────────────────────┐  │
/// │  │ Configuration│    │ PKPaymentAuthorization│  │
/// │  │              │───▶│    Controller         │  │
/// │  └──────────────┘    └───────────────────────┘  │
/// │         │                       │               │
/// │         ▼                       ▼               │
/// │  ┌──────────────┐    ┌───────────────────────┐  │
/// │  │ PaymentRequest│    │    Delegate          │  │
/// │  │   Builder    │    │    Handler            │  │
/// │  └──────────────┘    └───────────────────────┘  │
/// │         │                       │               │
/// │         └───────────┬───────────┘               │
/// │                     ▼                           │
/// │           ┌─────────────────┐                   │
/// │           │  PaymentResult  │                   │
/// │           └─────────────────┘                   │
/// └─────────────────────────────────────────────────┘
/// ```

@Observable
@MainActor
final class ApplePayService: NSObject {
    
    // MARK: - 상태
    
    /// 현재 결제 진행 상태
    private(set) var paymentState: PaymentState = .idle
    
    /// 선택된 배송 방법
    private(set) var selectedShippingMethod: ShippingMethod?
    
    /// 선택된 배송 연락처
    private(set) var selectedShippingContact: PKContact?
    
    /// 마지막 오류
    private(set) var lastError: PaymentError?
    
    // MARK: - 의존성
    
    /// 결제 설정
    let configuration: PaymentConfiguration
    
    // MARK: - 내부 상태
    
    /// 결제 완료 continuation (async/await 지원)
    private var paymentContinuation: CheckedContinuation<PaymentResult, Error>?
    
    /// 현재 결제 항목들
    private var currentCartItems: [CartItem] = []
    
    /// 현재 적용된 쿠폰 코드
    private var appliedCouponCode: String?
    
    /// 쿠폰 할인 금액
    private var couponDiscount: Int = 0
    
    // MARK: - 초기화
    
    /// 기본 설정으로 초기화
    init(configuration: PaymentConfiguration = .default) {
        self.configuration = configuration
        super.init()
    }
    
    // MARK: - 결제 가능 여부
    
    /// Apple Pay 사용 가능 여부
    var canMakePayments: Bool {
        configuration.canMakePayments
    }
    
    /// 등록된 카드로 결제 가능 여부
    var canMakePaymentsWithRegisteredCards: Bool {
        configuration.canMakePaymentsWithRegisteredCards
    }
    
    /// 결제 가능 상태
    var paymentAvailability: PaymentConfiguration.PaymentAvailability {
        configuration.paymentAvailability
    }
    
    /// Apple Pay 설정이 필요한지 여부
    var needsSetup: Bool {
        configuration.needsSetup
    }
    
    // MARK: - 결제 처리
    
    /// 장바구니 아이템으로 결제 처리
    /// - Parameters:
    ///   - items: 장바구니 아이템 배열
    ///   - shippingMethod: 선택된 배송 방법 (기본: 일반 배송)
    /// - Returns: 결제 결과
    /// - Throws: PaymentError
    func processPayment(
        for items: [CartItem],
        shippingMethod: ShippingMethod = .standardPaid
    ) async throws -> PaymentResult {
        // 상태 검증
        guard paymentState == .idle else {
            throw PaymentError.duplicatePayment
        }
        
        guard !items.isEmpty else {
            throw PaymentError.emptyPaymentItems
        }
        
        // 결제 가능 여부 확인
        switch paymentAvailability {
        case .notSupported:
            throw PaymentError.applePayNotSupported
        case .needsSetup:
            throw PaymentError.applePaySetupRequired
        case .available:
            break
        }
        
        // 상태 업데이트
        paymentState = .preparing
        currentCartItems = items
        selectedShippingMethod = shippingMethod
        lastError = nil
        
        // 결제 요청 생성
        let paymentRequest = createPaymentRequest(
            for: items,
            shippingMethod: shippingMethod
        )
        
        // 결제 컨트롤러 생성 및 표시
        return try await withCheckedThrowingContinuation { continuation in
            self.paymentContinuation = continuation
            
            let controller = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
            controller.delegate = self
            
            paymentState = .authorizing
            
            controller.present { [weak self] presented in
                if !presented {
                    self?.paymentState = .failed
                    self?.lastError = .authorizationFailed(underlyingError: nil)
                    continuation.resume(throwing: PaymentError.authorizationFailed(underlyingError: nil))
                    self?.paymentContinuation = nil
                }
            }
        }
    }
    
    /// 금액으로 직접 결제 처리
    /// - Parameter amount: 결제 금액
    /// - Returns: 결제 결과
    func processPayment(amount: Int) async throws -> PaymentResult {
        guard paymentState == .idle else {
            throw PaymentError.duplicatePayment
        }
        
        guard amount > 0 else {
            throw PaymentError.invalidAmount(Decimal(amount))
        }
        
        paymentState = .preparing
        lastError = nil
        
        let paymentRequest = configuration.createPaymentRequest(for: amount)
        
        return try await withCheckedThrowingContinuation { continuation in
            self.paymentContinuation = continuation
            
            let controller = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
            controller.delegate = self
            
            paymentState = .authorizing
            
            controller.present { [weak self] presented in
                if !presented {
                    self?.paymentState = .failed
                    self?.lastError = .authorizationFailed(underlyingError: nil)
                    continuation.resume(throwing: PaymentError.authorizationFailed(underlyingError: nil))
                    self?.paymentContinuation = nil
                }
            }
        }
    }
    
    /// 결제 상태 초기화
    func resetPayment() {
        paymentState = .idle
        selectedShippingMethod = nil
        selectedShippingContact = nil
        currentCartItems = []
        appliedCouponCode = nil
        couponDiscount = 0
        lastError = nil
        paymentContinuation = nil
    }
    
    // MARK: - 결제 요청 생성
    
    /// 장바구니 아이템으로 결제 요청 생성
    private func createPaymentRequest(
        for items: [CartItem],
        shippingMethod: ShippingMethod
    ) -> PKPaymentRequest {
        var summaryItems: [PKPaymentSummaryItem] = []
        
        // 개별 상품 항목
        for item in items {
            let label = item.quantity > 1
                ? "\(item.product.name) x \(item.quantity)"
                : item.product.name
            let amount = NSDecimalNumber(value: item.totalPrice)
            summaryItems.append(
                PKPaymentSummaryItem(label: label, amount: amount, type: .final)
            )
        }
        
        // 쿠폰 할인 (있는 경우)
        if couponDiscount > 0 {
            summaryItems.append(
                PKPaymentSummaryItem(
                    label: "쿠폰 할인",
                    amount: NSDecimalNumber(value: -couponDiscount),
                    type: .final
                )
            )
        }
        
        // 배송비
        let subtotal = items.reduce(0) { $0 + $1.totalPrice }
        let shippingCost = shippingMethod.calculatePrice(for: subtotal)
        if shippingCost > 0 {
            summaryItems.append(
                PKPaymentSummaryItem(
                    label: shippingMethod.name,
                    amount: NSDecimalNumber(value: shippingCost),
                    type: .final
                )
            )
        }
        
        // 총액
        let total = subtotal + shippingCost - couponDiscount
        summaryItems.append(
            PKPaymentSummaryItem(
                label: configuration.merchantDisplayName,
                amount: NSDecimalNumber(value: max(0, total)),
                type: .final
            )
        )
        
        // 배송 옵션
        let shippingMethods = ShippingMethod.toPKShippingMethods(
            ShippingMethod.defaultMethods,
            for: subtotal
        )
        
        return configuration.createPaymentRequest(
            items: summaryItems,
            shippingMethods: shippingMethods
        )
    }
    
    /// 결제 항목 업데이트
    private func updatedPaymentSummaryItems(
        for shippingMethod: PKShippingMethod?
    ) -> [PKPaymentSummaryItem] {
        var summaryItems: [PKPaymentSummaryItem] = []
        
        // 상품 항목
        for item in currentCartItems {
            let label = item.quantity > 1
                ? "\(item.product.name) x \(item.quantity)"
                : item.product.name
            summaryItems.append(
                PKPaymentSummaryItem(
                    label: label,
                    amount: NSDecimalNumber(value: item.totalPrice),
                    type: .final
                )
            )
        }
        
        // 쿠폰 할인
        if couponDiscount > 0 {
            summaryItems.append(
                PKPaymentSummaryItem(
                    label: "쿠폰 할인",
                    amount: NSDecimalNumber(value: -couponDiscount),
                    type: .final
                )
            )
        }
        
        // 배송비
        let subtotal = currentCartItems.reduce(0) { $0 + $1.totalPrice }
        let shippingCost = shippingMethod?.amount.intValue ?? 0
        
        if shippingCost > 0 {
            summaryItems.append(
                PKPaymentSummaryItem(
                    label: shippingMethod?.label ?? "배송",
                    amount: shippingMethod?.amount ?? NSDecimalNumber.zero,
                    type: .final
                )
            )
        }
        
        // 총액
        let total = subtotal + shippingCost - couponDiscount
        summaryItems.append(
            PKPaymentSummaryItem(
                label: configuration.merchantDisplayName,
                amount: NSDecimalNumber(value: max(0, total)),
                type: .final
            )
        )
        
        return summaryItems
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayService: PKPaymentAuthorizationControllerDelegate {
    
    /// 결제 승인 완료
    nonisolated func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        Task { @MainActor in
            paymentState = .processing
            
            do {
                // 실제 결제 처리 (서버 통신)
                let result = try await processPaymentWithServer(payment: payment)
                
                paymentState = .completed
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                
                // 성공 결과 반환
                paymentContinuation?.resume(returning: result)
                paymentContinuation = nil
                
            } catch let error as PaymentError {
                paymentState = .failed
                lastError = error
                
                // 에러 정보와 함께 실패 반환
                let pkErrors = error.toPKPaymentErrors()
                completion(PKPaymentAuthorizationResult(status: .failure, errors: pkErrors))
                
                paymentContinuation?.resume(throwing: error)
                paymentContinuation = nil
                
            } catch {
                paymentState = .failed
                let paymentError = PaymentError.unknown(underlyingError: error)
                lastError = paymentError
                
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                
                paymentContinuation?.resume(throwing: paymentError)
                paymentContinuation = nil
            }
        }
    }
    
    /// 결제 완료/취소
    nonisolated func paymentAuthorizationControllerDidFinish(
        _ controller: PKPaymentAuthorizationController
    ) {
        Task { @MainActor in
            controller.dismiss()
            
            // 사용자가 취소한 경우
            if paymentState == .authorizing {
                paymentState = .cancelled
                lastError = .userCancelled
                
                paymentContinuation?.resume(throwing: PaymentError.userCancelled)
                paymentContinuation = nil
            }
        }
    }
    
    /// 배송 연락처 선택/변경
    nonisolated func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact,
        handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void
    ) {
        Task { @MainActor in
            selectedShippingContact = contact
            
            // 주소 검증
            guard let postalCode = contact.postalAddress?.postalCode else {
                let error = PaymentError.invalidShippingAddress(reason: "우편번호를 확인할 수 없습니다.")
                completion(PKPaymentRequestShippingContactUpdate(
                    errors: error.toPKPaymentErrors(),
                    paymentSummaryItems: updatedPaymentSummaryItems(for: nil),
                    shippingMethods: []
                ))
                return
            }
            
            // 해당 지역에서 사용 가능한 배송 방법 필터링
            let availableMethods = ShippingMethod.availableMethods(
                from: ShippingMethod.defaultMethods,
                for: postalCode
            )
            
            let subtotal = currentCartItems.reduce(0) { $0 + $1.totalPrice }
            let pkShippingMethods = ShippingMethod.toPKShippingMethods(
                availableMethods,
                for: subtotal
            )
            
            // 첫 번째 배송 방법을 기본값으로 선택
            let defaultMethod = pkShippingMethods.first
            
            completion(PKPaymentRequestShippingContactUpdate(
                errors: nil,
                paymentSummaryItems: updatedPaymentSummaryItems(for: defaultMethod),
                shippingMethods: pkShippingMethods
            ))
        }
    }
    
    /// 배송 방법 선택/변경
    nonisolated func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod,
        handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void
    ) {
        Task { @MainActor in
            // ShippingMethod 찾기
            if let identifier = shippingMethod.identifier,
               let method = ShippingMethod.allMethods.first(where: { $0.id == identifier }) {
                selectedShippingMethod = method
            }
            
            let items = updatedPaymentSummaryItems(for: shippingMethod)
            completion(PKPaymentRequestShippingMethodUpdate(
                paymentSummaryItems: items
            ))
        }
    }
    
    /// 쿠폰 코드 입력
    nonisolated func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didChangeCouponCode couponCode: String,
        handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void
    ) {
        Task { @MainActor in
            // 쿠폰 코드 검증
            let result = await validateCouponCode(couponCode)
            
            switch result {
            case .success(let discount):
                appliedCouponCode = couponCode
                couponDiscount = discount
                
                completion(PKPaymentRequestCouponCodeUpdate(
                    errors: nil,
                    paymentSummaryItems: updatedPaymentSummaryItems(for: nil),
                    shippingMethods: []
                ))
                
            case .failure(let error):
                appliedCouponCode = nil
                couponDiscount = 0
                
                completion(PKPaymentRequestCouponCodeUpdate(
                    errors: error.toPKPaymentErrors(),
                    paymentSummaryItems: updatedPaymentSummaryItems(for: nil),
                    shippingMethods: []
                ))
            }
        }
    }
}

// MARK: - 서버 통신

extension ApplePayService {
    
    /// 서버에 결제 처리 요청
    /// - Parameter payment: Apple Pay 결제 정보
    /// - Returns: 결제 결과
    ///
    /// - Important: 실제 구현에서는 결제 게이트웨이 서버와 통신해야 함
    private func processPaymentWithServer(payment: PKPayment) async throws -> PaymentResult {
        // 결제 토큰 데이터
        let paymentData = payment.token.paymentData
        
        // 결제 네트워크 및 카드 타입
        let paymentMethod = payment.token.paymentMethod
        let network = paymentMethod.network?.rawValue ?? "Unknown"
        let cardType = paymentMethod.type.description
        
        // 트랜잭션 식별자
        let transactionId = payment.token.transactionIdentifier
        
        // 배송 정보
        let shippingContact = payment.shippingContact
        let billingContact = payment.billingContact
        
        // ⚠️ 실제 구현: 결제 게이트웨이 API 호출
        // 여기서는 Mock 구현
        
        // 네트워크 지연 시뮬레이션
        try await Task.sleep(for: .seconds(1))
        
        // 90% 확률로 성공 (테스트용)
        let success = Double.random(in: 0...1) > 0.1
        
        if success {
            // 주문 총액 계산
            let subtotal = currentCartItems.reduce(0) { $0 + $1.totalPrice }
            let shippingCost = selectedShippingMethod?.calculatePrice(for: subtotal) ?? 0
            let total = subtotal + shippingCost - couponDiscount
            
            return PaymentResult(
                transactionId: transactionId,
                status: .success,
                amount: total,
                currency: configuration.currencyCode,
                paymentNetwork: network,
                cardType: cardType,
                shippingContact: shippingContact,
                billingContact: billingContact,
                shippingMethod: selectedShippingMethod,
                timestamp: Date(),
                orderItems: currentCartItems.map { OrderItem(from: $0) }
            )
        } else {
            throw PaymentError.serverError(
                statusCode: 500,
                message: "결제 처리 중 서버 오류가 발생했습니다."
            )
        }
    }
    
    /// 쿠폰 코드 검증
    private func validateCouponCode(_ code: String) async -> Result<Int, PaymentError> {
        // ⚠️ 실제 구현: 서버에서 쿠폰 검증
        // 여기서는 Mock 구현
        
        try? await Task.sleep(for: .milliseconds(500))
        
        let validCoupons: [String: Int] = [
            "SAVE10": 10000,
            "SAVE20": 20000,
            "WELCOME": 5000,
            "FREESHIP": 3000
        ]
        
        let normalizedCode = code.uppercased().trimmingCharacters(in: .whitespaces)
        
        if let discount = validCoupons[normalizedCode] {
            return .success(discount)
        } else if normalizedCode == "EXPIRED" {
            return .failure(.couponExpired(code))
        } else {
            return .failure(.invalidCouponCode(code))
        }
    }
}

// MARK: - Apple Pay 설정 안내

extension ApplePayService {
    
    /// Wallet 앱으로 이동 (카드 추가 안내)
    func openWalletSettings() {
        if let url = URL(string: "shoebox://") {
            // Wallet 앱 URL Scheme
            Task { @MainActor in
                #if os(iOS)
                await UIApplication.shared.open(url)
                #endif
            }
        }
    }
    
    /// PKPassLibrary를 통한 카드 추가 시트 표시
    func presentAddCardSheet() {
        let library = PKPassLibrary()
        library.openPaymentSetup()
    }
}

// MARK: - 결제 상태

/// 결제 진행 상태
enum PaymentState: String, Sendable {
    /// 대기 상태
    case idle = "대기"
    /// 결제 준비 중
    case preparing = "준비 중"
    /// 결제 승인 대기 중
    case authorizing = "승인 대기"
    /// 결제 처리 중
    case processing = "처리 중"
    /// 결제 완료
    case completed = "완료"
    /// 결제 취소됨
    case cancelled = "취소됨"
    /// 결제 실패
    case failed = "실패"
    
    /// 결제 진행 중 여부
    var isInProgress: Bool {
        switch self {
        case .preparing, .authorizing, .processing:
            return true
        default:
            return false
        }
    }
    
    /// 최종 상태인지 여부
    var isFinal: Bool {
        switch self {
        case .completed, .cancelled, .failed:
            return true
        default:
            return false
        }
    }
}

// MARK: - 결제 결과

/// 결제 완료 결과
struct PaymentResult: Sendable {
    /// 트랜잭션 식별자
    let transactionId: String
    
    /// 결제 상태
    let status: Status
    
    /// 결제 금액
    let amount: Int
    
    /// 통화 코드
    let currency: String
    
    /// 결제 네트워크 (Visa, Mastercard 등)
    let paymentNetwork: String
    
    /// 카드 타입 (Credit, Debit 등)
    let cardType: String
    
    /// 배송 연락처
    let shippingContact: PKContact?
    
    /// 청구 연락처
    let billingContact: PKContact?
    
    /// 배송 방법
    let shippingMethod: ShippingMethod?
    
    /// 결제 시각
    let timestamp: Date
    
    /// 주문 항목
    let orderItems: [OrderItem]
    
    /// 결제 상태 열거형
    enum Status: String, Sendable {
        case success = "성공"
        case pending = "처리 중"
        case failed = "실패"
        case refunded = "환불됨"
    }
    
    /// 포맷팅된 금액
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "₩\(formatted)"
    }
    
    /// 포맷팅된 날짜
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
        return formatter.string(from: timestamp)
    }
}

/// 주문 항목
struct OrderItem: Sendable {
    let productId: UUID
    let productName: String
    let quantity: Int
    let unitPrice: Int
    let totalPrice: Int
    
    init(from cartItem: CartItem) {
        self.productId = cartItem.product.id
        self.productName = cartItem.product.name
        self.quantity = cartItem.quantity
        self.unitPrice = cartItem.product.price
        self.totalPrice = cartItem.totalPrice
    }
}

// MARK: - PKPaymentMethodType Extension

extension PKPaymentMethodType {
    var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .debit: return "Debit"
        case .credit: return "Credit"
        case .prepaid: return "Prepaid"
        case .store: return "Store"
        case .eMoney: return "eMoney"
        @unknown default: return "Unknown"
        }
    }
}

#if os(iOS)
import UIKit
#endif
