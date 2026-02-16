// MARK: - Chapter 6: Apple Pay 결제 기초

import PassKit
import SwiftUI

// 06-01-payment-flow.swift
/*
 Apple Pay 결제 흐름:
 
 1. 사용자 → 앱: "결제하기" 버튼 탭
 2. 앱 → iOS: PKPaymentRequest 생성 및 결제 시트 표시
 3. 사용자 → iOS: Face ID / Touch ID로 인증
 4. iOS → 앱: 암호화된 PKPaymentToken 전달
 5. 앱 → 서버: 토큰 전송
 6. 서버 → PG사: 토큰으로 결제 처리
 7. PG사 → 카드사: 실제 결제 요청
 8. 결과 반환 → 사용자에게 표시
*/

// 06-06-can-make-payments.swift
struct ApplePayAvailability {
    /// 기기가 Apple Pay를 지원하는지 확인
    var deviceSupportsApplePay: Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }
    
    /// 지원 네트워크의 카드가 등록되어 있는지 확인
    var hasRegisteredCards: Bool {
        PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: supportedNetworks
        )
    }
    
    private let supportedNetworks: [PKPaymentNetwork] = [
        .visa, .masterCard, .amex
    ]
}

// 06-08-setup-button.swift
struct SetupApplePayButton: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Apple Pay로 더 빠르게 결제하세요")
                .font(.headline)
            
            PaymentButton(.setUp, action: openWalletSettings)
                .frame(height: 50)
        }
    }
    
    private func openWalletSettings() {
        PKPassLibrary().openPaymentSetup()
    }
}

// 06-09-payment-button-swiftui.swift
struct CheckoutButton: View {
    let amount: Decimal
    let action: () -> Void
    
    private var canPay: Bool {
        PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: [.visa, .masterCard, .amex]
        )
    }
    
    var body: some View {
        if canPay {
            PaymentButton(.checkout, action: action)
                .frame(height: 50)
        } else if PKPaymentAuthorizationController.canMakePayments() {
            PaymentButton(.setUp, action: openWallet)
                .frame(height: 50)
        } else {
            Button("카드로 결제") {
                // 대체 결제 수단
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func openWallet() {
        PKPassLibrary().openPaymentSetup()
    }
}

// 06-10-button-style.swift
struct StyledPaymentButton: View {
    var body: some View {
        VStack(spacing: 12) {
            // 검정 배경
            PaymentButton(.buy, action: {})
                .paymentButtonStyle(.black)
            
            // 흰색 배경 (테두리 있음)
            PaymentButton(.buy, action: {})
                .paymentButtonStyle(.white)
            
            // 흰색 배경 (테두리 없음)
            PaymentButton(.buy, action: {})
                .paymentButtonStyle(.whiteOutline)
            
            // 시스템 자동 선택
            PaymentButton(.buy, action: {})
                .paymentButtonStyle(.automatic)
        }
        .frame(height: 50)
    }
}

// MARK: - Chapter 7: PKPaymentRequest 설정

// 07-01-basic-request.swift
func createBasicPaymentRequest() -> PKPaymentRequest {
    let request = PKPaymentRequest()
    
    // 필수 설정
    request.merchantIdentifier = "merchant.com.myapp.store"
    request.countryCode = "KR"
    request.currencyCode = "KRW"
    request.supportedNetworks = [.visa, .masterCard, .amex]
    request.merchantCapabilities = [.threeDSecure, .debit, .credit]
    
    return request
}

// 07-03-single-item.swift
func createSingleItemPayment(
    productName: String,
    price: Decimal,
    storeName: String
) -> PKPaymentRequest {
    let request = createBasicPaymentRequest()
    
    request.paymentSummaryItems = [
        PKPaymentSummaryItem(
            label: productName,
            amount: NSDecimalNumber(decimal: price)
        ),
        // 마지막 항목 = 총액 (가맹점 이름)
        PKPaymentSummaryItem(
            label: storeName,
            amount: NSDecimalNumber(decimal: price)
        )
    ]
    
    return request
}

// 07-04-multiple-items.swift
func createMultiItemPayment() -> PKPaymentRequest {
    let request = createBasicPaymentRequest()
    
    let product1 = PKPaymentSummaryItem(
        label: "MacBook Pro 14\"",
        amount: NSDecimalNumber(value: 2_690_000)
    )
    
    let product2 = PKPaymentSummaryItem(
        label: "Magic Keyboard",
        amount: NSDecimalNumber(value: 179_000)
    )
    
    let shipping = PKPaymentSummaryItem(
        label: "배송비",
        amount: NSDecimalNumber(value: 0) // 무료배송
    )
    
    let total = PKPaymentSummaryItem(
        label: "MyStore",
        amount: NSDecimalNumber(value: 2_869_000)
    )
    
    request.paymentSummaryItems = [product1, product2, shipping, total]
    return request
}

// 07-05-discount.swift
func createDiscountedPayment() -> PKPaymentRequest {
    let request = createBasicPaymentRequest()
    
    let subtotal = PKPaymentSummaryItem(
        label: "소계",
        amount: NSDecimalNumber(value: 100_000)
    )
    
    // 음수 금액으로 할인 표시
    let discount = PKPaymentSummaryItem(
        label: "멤버십 할인 (10%)",
        amount: NSDecimalNumber(value: -10_000)
    )
    
    let total = PKPaymentSummaryItem(
        label: "MyStore",
        amount: NSDecimalNumber(value: 90_000)
    )
    
    request.paymentSummaryItems = [subtotal, discount, total]
    return request
}

// 07-06-pending-amount.swift
func createPendingShippingPayment() -> PKPaymentRequest {
    let request = createBasicPaymentRequest()
    
    let subtotal = PKPaymentSummaryItem(
        label: "상품 금액",
        amount: NSDecimalNumber(value: 50_000)
    )
    
    // 배송비 미확정 (주소 선택 후 계산)
    let shipping = PKPaymentSummaryItem(
        label: "배송비",
        amount: NSDecimalNumber(value: 0),
        type: .pending // ← pending 타입
    )
    
    let total = PKPaymentSummaryItem(
        label: "MyStore",
        amount: NSDecimalNumber(value: 50_000),
        type: .pending
    )
    
    request.paymentSummaryItems = [subtotal, shipping, total]
    return request
}

// 07-11-request-builder.swift
class PaymentRequestBuilder {
    private var items: [PKPaymentSummaryItem] = []
    private let merchantId: String
    private let merchantName: String
    
    init(merchantId: String, merchantName: String) {
        self.merchantId = merchantId
        self.merchantName = merchantName
    }
    
    func addItem(_ label: String, amount: Decimal) -> Self {
        items.append(PKPaymentSummaryItem(
            label: label,
            amount: NSDecimalNumber(decimal: amount)
        ))
        return self
    }
    
    func addDiscount(_ label: String, amount: Decimal) -> Self {
        items.append(PKPaymentSummaryItem(
            label: label,
            amount: NSDecimalNumber(decimal: -amount)
        ))
        return self
    }
    
    func build() -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantId
        request.countryCode = "KR"
        request.currencyCode = "KRW"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = [.threeDSecure, .debit, .credit]
        
        // 총액 계산
        let total = items.reduce(Decimal.zero) { $0 + $1.amount.decimalValue }
        items.append(PKPaymentSummaryItem(
            label: merchantName,
            amount: NSDecimalNumber(decimal: total)
        ))
        
        request.paymentSummaryItems = items
        return request
    }
}

// 사용 예시
/*
let request = PaymentRequestBuilder(
    merchantId: "merchant.com.myapp",
    merchantName: "MyStore"
)
.addItem("MacBook Pro", amount: 2_690_000)
.addItem("AppleCare+", amount: 299_000)
.addDiscount("멤버십 할인", amount: 100_000)
.build()
*/
