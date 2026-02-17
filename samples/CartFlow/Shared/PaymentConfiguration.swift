import Foundation
import PassKit

// MARK: - 결제 설정
/// Apple Pay 결제에 필요한 설정 값들을 관리하는 구조체
///
/// ## 사용 예시
/// ```swift
/// let config = PaymentConfiguration.default
/// let request = config.createPaymentRequest(for: 50000)
/// ```
///
/// ## 중요 설정 항목
/// - `merchantIdentifier`: Apple Developer에서 등록한 Merchant ID
/// - `supportedNetworks`: 지원하는 카드 네트워크 목록
/// - `merchantCapabilities`: 3DS, EMV 등 지원 기능

struct PaymentConfiguration: Sendable {
    
    // MARK: - 기본 설정
    
    /// Apple Developer에서 등록한 Merchant Identifier
    /// - Important: 실제 앱에서는 Info.plist 또는 Configuration에서 로드해야 함
    let merchantIdentifier: String
    
    /// 상점 표시 이름 (결제 시트에 표시됨)
    let merchantDisplayName: String
    
    /// 국가 코드 (ISO 3166-1 alpha-2)
    let countryCode: String
    
    /// 통화 코드 (ISO 4217)
    let currencyCode: String
    
    /// 지원하는 카드 네트워크
    let supportedNetworks: [PKPaymentNetwork]
    
    /// 판매자 처리 능력 (3D Secure 등)
    let merchantCapabilities: PKMerchantCapability
    
    /// 필수 배송 정보 필드
    let requiredShippingContactFields: Set<PKContactField>
    
    /// 필수 청구 정보 필드
    let requiredBillingContactFields: Set<PKContactField>
    
    /// 배송 지원 여부
    let supportsShipping: Bool
    
    /// 쿠폰 코드 지원 여부 (iOS 15+)
    let supportsCouponCode: Bool
    
    // MARK: - 초기화
    
    /// 커스텀 설정으로 초기화
    /// - Parameters:
    ///   - merchantIdentifier: Merchant ID
    ///   - merchantDisplayName: 상점명
    ///   - countryCode: 국가 코드
    ///   - currencyCode: 통화 코드
    ///   - supportedNetworks: 지원 카드 네트워크
    ///   - merchantCapabilities: 판매자 기능
    ///   - requiredShippingContactFields: 필수 배송 정보
    ///   - requiredBillingContactFields: 필수 청구 정보
    ///   - supportsShipping: 배송 지원 여부
    ///   - supportsCouponCode: 쿠폰 지원 여부
    init(
        merchantIdentifier: String,
        merchantDisplayName: String,
        countryCode: String = "KR",
        currencyCode: String = "KRW",
        supportedNetworks: [PKPaymentNetwork] = Self.defaultNetworks,
        merchantCapabilities: PKMerchantCapability = Self.defaultCapabilities,
        requiredShippingContactFields: Set<PKContactField> = Self.defaultShippingFields,
        requiredBillingContactFields: Set<PKContactField> = Self.defaultBillingFields,
        supportsShipping: Bool = true,
        supportsCouponCode: Bool = true
    ) {
        self.merchantIdentifier = merchantIdentifier
        self.merchantDisplayName = merchantDisplayName
        self.countryCode = countryCode
        self.currencyCode = currencyCode
        self.supportedNetworks = supportedNetworks
        self.merchantCapabilities = merchantCapabilities
        self.requiredShippingContactFields = requiredShippingContactFields
        self.requiredBillingContactFields = requiredBillingContactFields
        self.supportsShipping = supportsShipping
        self.supportsCouponCode = supportsCouponCode
    }
    
    // MARK: - 기본 설정값
    
    /// 한국에서 지원되는 기본 카드 네트워크
    /// - Note: 실제 지원 여부는 Merchant 계약에 따라 다름
    static let defaultNetworks: [PKPaymentNetwork] = [
        .visa,
        .masterCard,
        .amex,
        .discover,
        .JCB,
        // iOS 14.5+
        .chinaUnionPay,
        // iOS 16+
        .maestro
    ]
    
    /// 기본 판매자 처리 능력
    /// - 3DS: 3D Secure 인증 지원 (EMV 3DS)
    /// - EMV: EMV 규격 지원
    static let defaultCapabilities: PKMerchantCapability = [
        .threeDSecure,
        .debit,
        .credit
    ]
    
    /// 기본 필수 배송 정보 필드
    static let defaultShippingFields: Set<PKContactField> = [
        .name,
        .postalAddress,
        .phoneNumber
    ]
    
    /// 기본 필수 청구 정보 필드
    static let defaultBillingFields: Set<PKContactField> = [
        .name,
        .postalAddress
    ]
    
    /// 기본 설정 (데모/테스트용)
    /// - Warning: 프로덕션에서는 실제 Merchant ID 사용 필요
    static let `default` = PaymentConfiguration(
        merchantIdentifier: "merchant.com.example.cartflow",
        merchantDisplayName: "CartFlow 스토어"
    )
    
    /// 배송 없는 디지털 상품용 설정
    static let digitalProducts = PaymentConfiguration(
        merchantIdentifier: "merchant.com.example.cartflow.digital",
        merchantDisplayName: "CartFlow 디지털",
        requiredShippingContactFields: [.emailAddress],
        requiredBillingContactFields: [.name],
        supportsShipping: false,
        supportsCouponCode: true
    )
}

// MARK: - PKPaymentRequest 생성

extension PaymentConfiguration {
    
    /// 결제 요청 생성
    /// - Parameters:
    ///   - amount: 결제 금액 (원화)
    ///   - items: 결제 항목 목록 (선택)
    ///   - shippingMethods: 배송 옵션 (선택)
    /// - Returns: 구성된 PKPaymentRequest
    ///
    /// ## 사용 예시
    /// ```swift
    /// let config = PaymentConfiguration.default
    /// let items = [
    ///     PKPaymentSummaryItem(label: "상품A", amount: 10000),
    ///     PKPaymentSummaryItem(label: "배송비", amount: 3000)
    /// ]
    /// let request = config.createPaymentRequest(items: items)
    /// ```
    func createPaymentRequest(
        items: [PKPaymentSummaryItem],
        shippingMethods: [PKShippingMethod]? = nil
    ) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        
        // 기본 설정
        request.merchantIdentifier = merchantIdentifier
        request.countryCode = countryCode
        request.currencyCode = currencyCode
        request.supportedNetworks = supportedNetworks
        request.merchantCapabilities = merchantCapabilities
        
        // 결제 항목
        request.paymentSummaryItems = items
        
        // 연락처 필드
        if supportsShipping {
            request.requiredShippingContactFields = requiredShippingContactFields
            if let methods = shippingMethods {
                request.shippingMethods = methods
                request.shippingType = .shipping
            }
        }
        request.requiredBillingContactFields = requiredBillingContactFields
        
        // 쿠폰 코드 지원 (iOS 15+)
        if supportsCouponCode {
            request.supportsCouponCode = true
        }
        
        return request
    }
    
    /// 단순 금액으로 결제 요청 생성
    /// - Parameter totalAmount: 총 결제 금액
    /// - Returns: 구성된 PKPaymentRequest
    func createPaymentRequest(for totalAmount: Int) -> PKPaymentRequest {
        let amount = NSDecimalNumber(value: totalAmount)
        let totalItem = PKPaymentSummaryItem(
            label: merchantDisplayName,
            amount: amount,
            type: .final
        )
        return createPaymentRequest(items: [totalItem])
    }
}

// MARK: - 결제 가능 여부 확인

extension PaymentConfiguration {
    
    /// Apple Pay 사용 가능 여부
    /// - Returns: 디바이스에서 Apple Pay를 사용할 수 있는지 여부
    ///
    /// ## 확인 항목
    /// 1. 디바이스의 Apple Pay 지원 여부
    /// 2. 지원 네트워크로 결제 가능한 카드 등록 여부
    var canMakePayments: Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }
    
    /// 등록된 카드로 결제 가능 여부
    /// - Returns: 지원 네트워크의 카드가 등록되어 있는지 여부
    var canMakePaymentsWithRegisteredCards: Bool {
        PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: supportedNetworks,
            capabilities: merchantCapabilities
        )
    }
    
    /// Apple Pay 설정 안내 필요 여부
    /// - Returns: 카드 설정이 필요한 경우 true
    ///
    /// 디바이스는 Apple Pay를 지원하지만 결제 가능한 카드가 없는 경우
    var needsSetup: Bool {
        canMakePayments && !canMakePaymentsWithRegisteredCards
    }
    
    /// 결제 가능 상태 열거형
    enum PaymentAvailability {
        /// Apple Pay 사용 가능, 카드 등록됨
        case available
        /// 카드 설정 필요
        case needsSetup
        /// Apple Pay 미지원 디바이스
        case notSupported
    }
    
    /// 현재 결제 가능 상태
    var paymentAvailability: PaymentAvailability {
        if canMakePaymentsWithRegisteredCards {
            return .available
        } else if canMakePayments {
            return .needsSetup
        } else {
            return .notSupported
        }
    }
}

// MARK: - Equatable, Hashable

extension PaymentConfiguration: Equatable {
    static func == (lhs: PaymentConfiguration, rhs: PaymentConfiguration) -> Bool {
        lhs.merchantIdentifier == rhs.merchantIdentifier &&
        lhs.countryCode == rhs.countryCode &&
        lhs.currencyCode == rhs.currencyCode
    }
}

extension PaymentConfiguration: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(merchantIdentifier)
        hasher.combine(countryCode)
        hasher.combine(currencyCode)
    }
}

// MARK: - Debug Description

extension PaymentConfiguration: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        PaymentConfiguration(
            merchantIdentifier: \(merchantIdentifier),
            merchantDisplayName: \(merchantDisplayName),
            countryCode: \(countryCode),
            currencyCode: \(currencyCode),
            supportedNetworks: \(supportedNetworks.map { $0.rawValue }),
            supportsShipping: \(supportsShipping),
            paymentAvailability: \(paymentAvailability)
        )
        """
    }
}
