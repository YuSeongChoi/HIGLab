import Foundation
import PassKit

@Observable
final class PaymentManager: NSObject {
    private(set) var canMakePayments: Bool = false
    private(set) var paymentStatus: PaymentStatus = .idle
    
    private var paymentCompletion: ((Bool) -> Void)?
    
    enum PaymentStatus {
        case idle
        case processing
        case success
        case failed(Error)
    }
    
    override init() {
        super.init()
        canMakePayments = PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: [.visa, .masterCard, .amex]
        )
    }
    
    // MARK: - Payment Request 생성
    func createPaymentRequest(for items: [(name: String, amount: Decimal)]) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        
        // 가맹점 정보
        request.merchantIdentifier = "merchant.com.higlab.ecommerce"
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "KR"
        request.currencyCode = "KRW"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        
        // 결제 항목
        var paymentItems: [PKPaymentSummaryItem] = items.map { item in
            PKPaymentSummaryItem(
                label: item.name,
                amount: item.amount as NSDecimalNumber
            )
        }
        
        // 합계
        let total = items.reduce(Decimal.zero) { $0 + $1.amount }
        paymentItems.append(
            PKPaymentSummaryItem(
                label: "HIG Lab Store",
                amount: total as NSDecimalNumber
            )
        )
        
        request.paymentSummaryItems = paymentItems
        
        // 필요한 배송 정보
        request.requiredShippingContactFields = [.postalAddress, .phoneNumber]
        
        return request
    }
    
    // MARK: - Apple Pay 실행
    @MainActor
    func startPayment(request: PKPaymentRequest) async -> Bool {
        guard canMakePayments else { return false }
        
        paymentStatus = .processing
        
        return await withCheckedContinuation { continuation in
            paymentCompletion = { success in
                continuation.resume(returning: success)
            }
            
            let controller = PKPaymentAuthorizationController(paymentRequest: request)
            controller.delegate = self
            
            Task { @MainActor in
                await controller.present()
            }
        }
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate
extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // 실제 앱에서는 payment.token을 서버로 전송하여 처리
        // 여기서는 시뮬레이션으로 성공 처리
        
        Task { @MainActor in
            // 결제 처리 시뮬레이션 (서버 통신)
            try? await Task.sleep(for: .seconds(1))
            
            paymentStatus = .success
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
        
        let success = if case .success = paymentStatus { true } else { false }
        paymentCompletion?(success)
        paymentCompletion = nil
    }
}
