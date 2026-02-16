// MARK: - Chapter 9: In-App Provisioning

import PassKit

// 09-03-can-add-card.swift
func checkCardProvisioningEligibility(
    primaryAccountIdentifier: String
) -> ProvisioningStatus {
    let passLibrary = PKPassLibrary()
    
    // iPhone에 추가 가능한지 확인
    let canAddToPhone = passLibrary.canAddSecureElementPass(
        primaryAccountIdentifier: primaryAccountIdentifier
    )
    
    return ProvisioningStatus(
        canAddToPhone: canAddToPhone,
        primaryAccountIdentifier: primaryAccountIdentifier
    )
}

struct ProvisioningStatus {
    let canAddToPhone: Bool
    let primaryAccountIdentifier: String
}

// 09-04-already-added.swift
func isCardAlreadyInWallet(primaryAccountSuffix: String) -> Bool {
    let passLibrary = PKPassLibrary()
    let passes = passLibrary.passes(of: .secureElement)
    
    return passes.contains { pass in
        pass.secureElementPass?.primaryAccountNumberSuffix == primaryAccountSuffix
    }
}

// 09-06-pass-configuration.swift
func createProvisioningConfiguration(
    cardholderName: String,
    primaryAccountSuffix: String
) -> PKAddPaymentPassRequestConfiguration? {
    
    let config = PKAddPaymentPassRequestConfiguration(
        encryptionScheme: .ECC_V2
    )
    
    config?.cardholderName = cardholderName
    config?.primaryAccountSuffix = primaryAccountSuffix
    config?.localizedDescription = "My Bank Visa Card"
    config?.paymentNetwork = .visa
    
    return config
}

// 09-07-show-vc.swift
import UIKit

class ProvisioningViewController: UIViewController {
    func presentProvisioningUI(configuration: PKAddPaymentPassRequestConfiguration) {
        guard let provisioningVC = PKAddPaymentPassViewController(
            requestConfiguration: configuration,
            delegate: self
        ) else {
            print("프로비저닝 UI 생성 실패")
            return
        }
        
        present(provisioningVC, animated: true)
    }
}

// 09-08-generate-request.swift
extension ProvisioningViewController: PKAddPaymentPassViewControllerDelegate {
    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        generateRequestWithCertificateChain certificates: [Data],
        nonce: Data,
        nonceSignature: Data,
        completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
    ) {
        // 서버로 인증서 체인과 nonce 전송
        Task {
            do {
                let request = try await requestProvisioningData(
                    certificates: certificates,
                    nonce: nonce,
                    nonceSignature: nonceSignature
                )
                handler(request)
            } catch {
                print("프로비저닝 데이터 요청 실패: \(error)")
                handler(PKAddPaymentPassRequest())
            }
        }
    }
    
    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        didFinishAdding pass: PKPaymentPass?,
        error: Error?
    ) {
        controller.dismiss(animated: true)
        
        if let pass = pass {
            print("카드 추가 성공: \(pass.primaryAccountNumberSuffix)")
            showSuccessUI()
        } else if let error = error {
            print("카드 추가 실패: \(error.localizedDescription)")
            showErrorUI(error)
        }
    }
    
    private func requestProvisioningData(
        certificates: [Data],
        nonce: Data,
        nonceSignature: Data
    ) async throws -> PKAddPaymentPassRequest {
        // 서버 API 호출
        let response = try await callProvisioningAPI(
            certificates: certificates,
            nonce: nonce,
            nonceSignature: nonceSignature
        )
        
        let request = PKAddPaymentPassRequest()
        request.encryptedPassData = response.encryptedPassData
        request.activationData = response.activationData
        request.ephemeralPublicKey = response.ephemeralPublicKey
        
        return request
    }
    
    private func callProvisioningAPI(
        certificates: [Data],
        nonce: Data,
        nonceSignature: Data
    ) async throws -> ProvisioningResponse {
        // 실제 서버 API 구현
        fatalError("서버 API 구현 필요")
    }
    
    private func showSuccessUI() {}
    private func showErrorUI(_ error: Error) {}
}

struct ProvisioningResponse {
    let encryptedPassData: Data
    let activationData: Data
    let ephemeralPublicKey: Data
}

// MARK: - Chapter 10: 결제 시트 커스터마이징

// 10-01-shipping-request.swift
func createRequestWithShipping() -> PKPaymentRequest {
    let request = PKPaymentRequest()
    request.merchantIdentifier = "merchant.com.myapp"
    request.countryCode = "KR"
    request.currencyCode = "KRW"
    request.supportedNetworks = [.visa, .masterCard, .amex]
    request.merchantCapabilities = [.threeDSecure]
    
    // 배송 정보 요청
    request.requiredShippingContactFields = [
        .postalAddress,  // 주소
        .name,           // 이름
        .phoneNumber,    // 전화번호
        .emailAddress    // 이메일
    ]
    
    request.paymentSummaryItems = [
        PKPaymentSummaryItem(label: "MyStore", amount: NSDecimalNumber(value: 50000))
    ]
    
    return request
}

// 10-02-billing-request.swift
func createRequestWithBilling() -> PKPaymentRequest {
    let request = createRequestWithShipping()
    
    // 청구 정보 요청
    request.requiredBillingContactFields = [
        .postalAddress,
        .name
    ]
    
    return request
}

// 10-04-shipping-methods.swift
func createShippingMethods() -> [PKShippingMethod] {
    let standard = PKShippingMethod(
        label: "일반 배송",
        amount: NSDecimalNumber(value: 3000)
    )
    standard.identifier = "standard"
    standard.detail = "3-5일 소요"
    
    let express = PKShippingMethod(
        label: "익일 배송",
        amount: NSDecimalNumber(value: 5000)
    )
    express.identifier = "express"
    express.detail = "내일 도착"
    
    let free = PKShippingMethod(
        label: "무료 배송",
        amount: NSDecimalNumber(value: 0)
    )
    free.identifier = "free"
    free.detail = "5만원 이상 주문 시 (5-7일)"
    
    return [free, standard, express]
}

// 10-06-method-change.swift
extension PaymentController {
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod,
        handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void
    ) {
        let productAmount: Decimal = 50000
        let shippingAmount = shippingMethod.amount.decimalValue
        let total = productAmount + shippingAmount
        
        let newItems = [
            PKPaymentSummaryItem(label: "상품", amount: NSDecimalNumber(decimal: productAmount)),
            PKPaymentSummaryItem(label: "배송비", amount: shippingMethod.amount),
            PKPaymentSummaryItem(label: "MyStore", amount: NSDecimalNumber(decimal: total))
        ]
        
        let update = PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: newItems)
        completion(update)
    }
}

// 10-07-contact-change.swift
extension PaymentController {
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact,
        handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void
    ) {
        guard let postalCode = contact.postalAddress?.postalCode else {
            completion(PKPaymentRequestShippingContactUpdate())
            return
        }
        
        // 지역별 배송비 계산
        let shippingCost = calculateShipping(for: postalCode)
        
        if shippingCost < 0 {
            // 배송 불가 지역
            let error = PKPaymentRequest.paymentShippingAddressInvalidError(
                withKey: CNPostalAddressPostalCodeKey,
                localizedDescription: "해당 지역은 배송이 불가합니다"
            )
            completion(PKPaymentRequestShippingContactUpdate(errors: [error], paymentSummaryItems: [], shippingMethods: []))
        } else {
            let items = [
                PKPaymentSummaryItem(label: "상품", amount: NSDecimalNumber(value: 50000)),
                PKPaymentSummaryItem(label: "배송비", amount: NSDecimalNumber(decimal: shippingCost)),
                PKPaymentSummaryItem(label: "MyStore", amount: NSDecimalNumber(decimal: 50000 + shippingCost))
            ]
            completion(PKPaymentRequestShippingContactUpdate(errors: nil, paymentSummaryItems: items, shippingMethods: createShippingMethods()))
        }
    }
    
    private func calculateShipping(for postalCode: String) -> Decimal {
        // 제주도/도서산간
        if postalCode.hasPrefix("63") {
            return 5000
        }
        // 일반 지역
        return 3000
    }
}

// 10-10-coupon-support.swift
func createRequestWithCoupon() -> PKPaymentRequest {
    let request = createBasicPaymentRequest()
    
    // 쿠폰 코드 지원 활성화 (iOS 15+)
    request.supportsCouponCode = true
    
    return request
}

// 10-11-coupon-validation.swift
extension PaymentController {
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didChangeCouponCode couponCode: String,
        handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void
    ) {
        Task {
            let result = await validateCoupon(code: couponCode)
            
            if let discount = result.discount {
                let items = [
                    PKPaymentSummaryItem(label: "상품", amount: NSDecimalNumber(value: 50000)),
                    PKPaymentSummaryItem(label: "쿠폰 할인 (\(couponCode))", amount: NSDecimalNumber(value: -discount)),
                    PKPaymentSummaryItem(label: "MyStore", amount: NSDecimalNumber(value: 50000 - discount))
                ]
                completion(PKPaymentRequestCouponCodeUpdate(errors: nil, paymentSummaryItems: items, shippingMethods: []))
            } else {
                let error = PKPaymentRequest.paymentCouponCodeInvalidError(
                    localizedDescription: "유효하지 않은 쿠폰 코드입니다"
                )
                completion(PKPaymentRequestCouponCodeUpdate(errors: [error], paymentSummaryItems: [], shippingMethods: []))
            }
        }
    }
    
    private func validateCoupon(code: String) async -> (discount: Int?, message: String?) {
        // 서버에서 쿠폰 검증
        switch code.uppercased() {
        case "WELCOME10":
            return (5000, nil)
        case "VIP20":
            return (10000, nil)
        default:
            return (nil, "유효하지 않은 쿠폰")
        }
    }
}

// 10-13-recurring-payment.swift
func createRecurringPaymentRequest() -> PKPaymentRequest {
    let request = createBasicPaymentRequest()
    
    // 정기 결제 항목
    let recurringItem = PKRecurringPaymentSummaryItem(
        label: "Premium 구독",
        amount: NSDecimalNumber(value: 9900)
    )
    recurringItem.intervalUnit = .month
    recurringItem.intervalCount = 1 // 매월
    
    request.paymentSummaryItems = [recurringItem]
    
    // 정기 결제 상세 설정 (iOS 16+)
    let recurringRequest = PKRecurringPaymentRequest(
        paymentDescription: "MyApp Premium 월간 구독",
        regularBilling: recurringItem,
        managementURL: URL(string: "https://myapp.com/subscription")!
    )
    request.recurringPaymentRequest = recurringRequest
    
    return request
}
