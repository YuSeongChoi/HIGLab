# PassKit AI Reference

> Apple Pay 및 Wallet 통합 가이드. 이 문서를 읽고 PassKit 코드를 생성할 수 있습니다.

## 개요

PassKit은 Apple Pay 결제와 Wallet 패스(탑승권, 티켓 등)를 관리하는 프레임워크입니다.
간편한 결제 UI와 패스 추가 기능을 제공합니다.

## 필수 Import

```swift
import PassKit
```

## 프로젝트 설정

1. **Capabilities**: Apple Pay 추가
2. **Merchant ID**: Apple Developer에서 생성
3. **Payment Processing Certificate**: 결제 처리용 인증서

## 핵심 구성요소

### 1. Apple Pay 지원 확인

```swift
// Apple Pay 사용 가능 여부
let canMakePayments = PKPaymentAuthorizationController.canMakePayments()

// 특정 카드 네트워크 지원 확인
let networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
let canMakePaymentsWithNetworks = PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
```

### 2. 결제 요청 생성

```swift
func createPaymentRequest() -> PKPaymentRequest {
    let request = PKPaymentRequest()
    
    // 가맹점 정보
    request.merchantIdentifier = "merchant.com.yourcompany.app"
    request.merchantCapabilities = [.capability3DS, .capabilityDebit, .capabilityCredit]
    
    // 지원 카드
    request.supportedNetworks = [.visa, .masterCard, .amex]
    
    // 국가 및 통화
    request.countryCode = "KR"
    request.currencyCode = "KRW"
    
    // 결제 항목
    request.paymentSummaryItems = [
        PKPaymentSummaryItem(label: "상품 A", amount: NSDecimalNumber(value: 10000)),
        PKPaymentSummaryItem(label: "배송비", amount: NSDecimalNumber(value: 3000)),
        PKPaymentSummaryItem(label: "내 가게", amount: NSDecimalNumber(value: 13000), type: .final)
    ]
    
    return request
}
```

### 3. Apple Pay 버튼

```swift
import SwiftUI
import PassKit

struct ApplePayButton: UIViewRepresentable {
    let action: () -> Void
    
    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func buttonTapped() {
            action()
        }
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI
import PassKit

// MARK: - Cart Item
struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Decimal
    var quantity: Int
    
    var total: Decimal {
        price * Decimal(quantity)
    }
}

// MARK: - Payment Manager
@Observable
class PaymentManager: NSObject {
    var cartItems: [CartItem] = []
    var paymentStatus: PaymentStatus = .idle
    
    enum PaymentStatus {
        case idle
        case processing
        case success
        case failed(Error)
    }
    
    var canUseApplePay: Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    }
    
    private let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
    private let merchantIdentifier = "merchant.com.example.app"
    
    var subtotal: Decimal {
        cartItems.reduce(0) { $0 + $1.total }
    }
    
    var shippingCost: Decimal {
        subtotal >= 50000 ? 0 : 3000
    }
    
    var total: Decimal {
        subtotal + shippingCost
    }
    
    func startPayment() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.merchantCapabilities = [.capability3DS, .capabilityDebit, .capabilityCredit]
        request.supportedNetworks = supportedNetworks
        request.countryCode = "KR"
        request.currencyCode = "KRW"
        
        // 결제 항목 구성
        var summaryItems: [PKPaymentSummaryItem] = cartItems.map { item in
            PKPaymentSummaryItem(
                label: "\(item.name) x\(item.quantity)",
                amount: NSDecimalNumber(decimal: item.total)
            )
        }
        
        if shippingCost > 0 {
            summaryItems.append(PKPaymentSummaryItem(
                label: "배송비",
                amount: NSDecimalNumber(decimal: shippingCost)
            ))
        }
        
        summaryItems.append(PKPaymentSummaryItem(
            label: "내 가게",
            amount: NSDecimalNumber(decimal: total),
            type: .final
        ))
        
        request.paymentSummaryItems = summaryItems
        
        // 결제 시트 표시
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller?.delegate = self
        controller?.present()
        
        paymentStatus = .processing
    }
}

extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, 
                                        didAuthorizePayment payment: PKPayment, 
                                        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // 서버로 결제 토큰 전송
        let token = payment.token.paymentData
        
        // 실제 앱에서는 서버 API 호출
        Task {
            do {
                // let result = try await PaymentAPI.process(token: token)
                
                // 성공 시뮬레이션
                try await Task.sleep(for: .seconds(1))
                
                await MainActor.run {
                    paymentStatus = .success
                }
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            } catch {
                await MainActor.run {
                    paymentStatus = .failed(error)
                }
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }
}

// MARK: - Views
struct CheckoutView: View {
    @State private var paymentManager = PaymentManager()
    
    var body: some View {
        NavigationStack {
            VStack {
                // 장바구니 목록
                List {
                    ForEach(paymentManager.cartItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(item.quantity)개")
                                .foregroundStyle(.secondary)
                            Text("₩\(NSDecimalNumber(decimal: item.total).intValue)")
                        }
                    }
                }
                
                // 요약
                VStack(spacing: 8) {
                    HStack {
                        Text("소계")
                        Spacer()
                        Text("₩\(NSDecimalNumber(decimal: paymentManager.subtotal).intValue)")
                    }
                    
                    HStack {
                        Text("배송비")
                        Spacer()
                        Text(paymentManager.shippingCost > 0 ? "₩\(NSDecimalNumber(decimal: paymentManager.shippingCost).intValue)" : "무료")
                    }
                    .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Text("총액")
                            .font(.headline)
                        Spacer()
                        Text("₩\(NSDecimalNumber(decimal: paymentManager.total).intValue)")
                            .font(.headline)
                    }
                }
                .padding()
                .background(.regularMaterial)
                
                // Apple Pay 버튼
                if paymentManager.canUseApplePay {
                    ApplePayButton {
                        paymentManager.startPayment()
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                } else {
                    Button("다른 결제 방법") {
                        // 대체 결제
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("결제")
            .onAppear {
                // 샘플 데이터
                paymentManager.cartItems = [
                    CartItem(name: "상품 A", price: 15000, quantity: 2),
                    CartItem(name: "상품 B", price: 8000, quantity: 1)
                ]
            }
            .alert("결제 완료", isPresented: .constant(paymentManager.paymentStatus == .success)) {
                Button("확인") {
                    paymentManager.paymentStatus = .idle
                }
            }
        }
    }
}

// 결제 상태 비교를 위한 Equatable
extension PaymentManager.PaymentStatus: Equatable {
    static func == (lhs: PaymentManager.PaymentStatus, rhs: PaymentManager.PaymentStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.processing, .processing), (.success, .success):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
```

## 고급 패턴

### 1. Wallet 패스 추가

```swift
func addPassToWallet(passData: Data) {
    guard let pass = try? PKPass(data: passData) else { return }
    
    let library = PKPassLibrary()
    
    if library.containsPass(pass) {
        // 이미 추가됨
        return
    }
    
    let controller = PKAddPassesViewController(pass: pass)
    // present controller
}

// SwiftUI
struct AddToWalletButton: View {
    let passURL: URL
    
    var body: some View {
        PKAddPassButton(.add) {
            // 패스 추가 로직
        }
    }
}
```

### 2. 배송 옵션

```swift
func createRequestWithShipping() -> PKPaymentRequest {
    let request = createPaymentRequest()
    
    request.requiredShippingContactFields = [.postalAddress, .name, .phoneNumber]
    request.requiredBillingContactFields = [.postalAddress]
    
    request.shippingMethods = [
        PKShippingMethod(label: "일반 배송", amount: NSDecimalNumber(value: 3000)),
        PKShippingMethod(label: "빠른 배송", amount: NSDecimalNumber(value: 5000))
    ]
    request.shippingMethods?[0].identifier = "standard"
    request.shippingMethods?[1].identifier = "express"
    
    return request
}

// Delegate에서 배송 방법 변경 처리
func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                    didSelect shippingMethod: PKShippingMethod,
                                    handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
    // 배송비에 따라 총액 재계산
    let newItems = calculateItems(with: shippingMethod)
    completion(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: newItems))
}
```

### 3. 구독 결제

```swift
let recurringItem = PKRecurringPaymentSummaryItem(
    label: "월간 구독",
    amount: NSDecimalNumber(value: 9900)
)
recurringItem.intervalUnit = .month
recurringItem.intervalCount = 1
recurringItem.startDate = Date()
recurringItem.endDate = nil  // 무기한

request.paymentSummaryItems = [recurringItem]
request.recurringPaymentRequest = PKRecurringPaymentRequest(
    paymentDescription: "월간 프리미엄 구독",
    regularBilling: recurringItem,
    managementURL: URL(string: "https://example.com/manage")!
)
```

## 주의사항

1. **시뮬레이터 테스트**
   - Apple Pay는 실제 기기에서만 완전 테스트 가능
   - 시뮬레이터에서는 UI만 확인 가능

2. **Merchant ID 설정**
   - Apple Developer에서 생성 필요
   - Xcode Capabilities에 추가

3. **결제 토큰 처리**
   - `PKPayment.token.paymentData`를 서버로 전송
   - 서버에서 결제 프로세서(Stripe, Toss 등)로 전달

4. **에러 처리**
   ```swift
   switch payment.token.paymentMethod.type {
   case .debit:
       // 체크카드
   case .credit:
       // 신용카드
   default:
       break
   }
   ```
