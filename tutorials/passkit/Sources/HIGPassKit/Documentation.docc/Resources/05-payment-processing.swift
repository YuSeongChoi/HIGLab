// MARK: - Chapter 8: 결제 처리

import PassKit
import SwiftUI

// 08-01-show-sheet.swift
class PaymentController {
    func startPayment(with request: PKPaymentRequest) {
        guard let controller = PKPaymentAuthorizationController(paymentRequest: request) else {
            print("결제 요청 생성 실패")
            return
        }
        
        controller.delegate = self
        controller.present { presented in
            if !presented {
                print("결제 시트 표시 실패")
            }
        }
    }
}

// 08-02-delegate.swift
extension PaymentController: PKPaymentAuthorizationControllerDelegate {
    // 필수 메서드 1: 결제 인증 완료
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // 서버로 토큰 전송 및 결제 처리
        processPayment(payment) { result in
            completion(result)
        }
    }
    
    // 필수 메서드 2: 결제 시트 닫힘
    func paymentAuthorizationControllerDidFinish(
        _ controller: PKPaymentAuthorizationController
    ) {
        controller.dismiss()
    }
    
    private func processPayment(
        _ payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // 구현 필요
    }
}

// 08-03-receive-payment.swift
func handleAuthorizedPayment(_ payment: PKPayment) {
    // PKPayment에서 추출 가능한 정보
    let token = payment.token
    let paymentMethod = token.paymentMethod
    
    print("카드 네트워크: \(paymentMethod.network?.rawValue ?? "Unknown")")
    print("카드 타입: \(paymentMethod.type.rawValue)")
    print("표시 이름: \(paymentMethod.displayName ?? "N/A")")
    
    // 암호화된 결제 데이터
    let paymentData = token.paymentData
    print("Payment Data: \(paymentData.count) bytes")
    
    // 청구/배송 주소 (요청한 경우)
    if let billing = payment.billingContact {
        print("청구 주소: \(billing.postalAddress?.city ?? "")")
    }
    
    if let shipping = payment.shippingContact {
        print("배송 주소: \(shipping.postalAddress?.city ?? "")")
    }
}

// 08-04-send-token.swift
func sendTokenToServer(_ payment: PKPayment) async throws -> PaymentResult {
    let tokenData = payment.token.paymentData
    let base64Token = tokenData.base64EncodedString()
    
    let payload: [String: Any] = [
        "paymentToken": base64Token,
        "transactionId": payment.token.transactionIdentifier,
        "paymentNetwork": payment.token.paymentMethod.network?.rawValue ?? "",
        "amount": 50000, // 실제 금액
        "currency": "KRW"
    ]
    
    let url = URL(string: "https://api.myapp.com/payments")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: payload)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(PaymentResult.self, from: data)
}

struct PaymentResult: Codable {
    let success: Bool
    let transactionId: String?
    let errorMessage: String?
}

// 08-05-process-payment.swift
func processPaymentWithServer(
    _ payment: PKPayment,
    completion: @escaping (PKPaymentAuthorizationResult) -> Void
) {
    Task {
        do {
            let result = try await sendTokenToServer(payment)
            
            if result.success {
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            } else {
                let error = PKPaymentRequest.paymentBillingAddressInvalidError(
                    withKey: CNPostalAddressStreetKey,
                    localizedDescription: result.errorMessage ?? "결제 실패"
                )
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
        } catch {
            completion(PKPaymentAuthorizationResult(
                status: .failure,
                errors: [error]
            ))
        }
    }
}

// 08-06-success-result.swift
func createSuccessResult() -> PKPaymentAuthorizationResult {
    return PKPaymentAuthorizationResult(status: .success, errors: nil)
}

// 08-07-failure-result.swift
import Contacts

func createFailureResult(reason: String) -> PKPaymentAuthorizationResult {
    let error = NSError(
        domain: PKPaymentErrorDomain,
        code: PKPaymentError.unknownError.rawValue,
        userInfo: [NSLocalizedDescriptionKey: reason]
    )
    
    return PKPaymentAuthorizationResult(status: .failure, errors: [error])
}

// 08-08-field-errors.swift
func createAddressError() -> PKPaymentAuthorizationResult {
    let errors: [Error] = [
        PKPaymentRequest.paymentShippingAddressInvalidError(
            withKey: CNPostalAddressPostalCodeKey,
            localizedDescription: "배송 불가 지역입니다"
        ),
        PKPaymentRequest.paymentContactInvalidError(
            withKey: CNContactPhoneNumbersKey,
            localizedDescription: "유효한 연락처를 입력하세요"
        )
    ]
    
    return PKPaymentAuthorizationResult(status: .failure, errors: errors)
}

// 08-11-payment-handler.swift
@MainActor
class PaymentHandler: NSObject, ObservableObject {
    @Published var paymentStatus: PaymentStatus = .idle
    @Published var lastTransactionId: String?
    
    enum PaymentStatus {
        case idle
        case processing
        case success
        case failed(String)
    }
    
    private var paymentController: PKPaymentAuthorizationController?
    
    func startApplePay(request: PKPaymentRequest) {
        guard let controller = PKPaymentAuthorizationController(paymentRequest: request) else {
            paymentStatus = .failed("결제 초기화 실패")
            return
        }
        
        paymentController = controller
        controller.delegate = self
        
        controller.present { [weak self] presented in
            if !presented {
                self?.paymentStatus = .failed("결제 시트 표시 실패")
            } else {
                self?.paymentStatus = .processing
            }
        }
    }
}

extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        Task {
            do {
                let result = try await sendTokenToServer(payment)
                if result.success {
                    await MainActor.run {
                        self.lastTransactionId = result.transactionId
                        self.paymentStatus = .success
                    }
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                } else {
                    await MainActor.run {
                        self.paymentStatus = .failed(result.errorMessage ?? "결제 실패")
                    }
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                }
            } catch {
                await MainActor.run {
                    self.paymentStatus = .failed(error.localizedDescription)
                }
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
        }
    }
    
    func paymentAuthorizationControllerDidFinish(
        _ controller: PKPaymentAuthorizationController
    ) {
        controller.dismiss()
        paymentController = nil
    }
}

// 08-12-payment-view.swift
struct PaymentView: View {
    @StateObject private var paymentHandler = PaymentHandler()
    let amount: Decimal = 50000
    
    var body: some View {
        VStack(spacing: 20) {
            Text("결제 금액: ₩\(amount, format: .number)")
                .font(.title)
            
            switch paymentHandler.paymentStatus {
            case .idle:
                PaymentButton(.buy) {
                    let request = createPaymentRequest(amount: amount)
                    paymentHandler.startApplePay(request: request)
                }
                .frame(height: 50)
                
            case .processing:
                ProgressView("결제 처리 중...")
                
            case .success:
                Label("결제 완료!", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
            case .failed(let message):
                VStack {
                    Label("결제 실패", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text(message)
                        .font(.caption)
                }
            }
        }
        .padding()
    }
    
    private func createPaymentRequest(amount: Decimal) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.myapp"
        request.countryCode = "KR"
        request.currencyCode = "KRW"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = [.threeDSecure]
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "MyStore", amount: NSDecimalNumber(decimal: amount))
        ]
        return request
    }
}
