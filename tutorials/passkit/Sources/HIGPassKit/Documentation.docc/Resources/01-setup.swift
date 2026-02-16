// MARK: - Chapter 1: PassKit 소개 & Wallet

// 01-01-import.swift
import PassKit
import SwiftUI

// 01-02-availability.swift
func checkWalletAvailability() -> Bool {
    // Wallet 앱 사용 가능 여부 확인
    return PKPassLibrary.isPassLibraryAvailable()
}

// 01-03-pass-types.swift
enum PassType: String {
    case boardingPass   // 항공권, 기차표
    case coupon         // 할인 쿠폰
    case eventTicket    // 콘서트, 영화 티켓
    case storeCard      // 멤버십, 포인트 카드 ✅
    case generic        // 범용 패스
}

// 01-04-pass-library.swift
class PassManager {
    private let passLibrary = PKPassLibrary()
    
    // 사용자의 모든 패스 가져오기
    func getAllPasses() -> [PKPass] {
        return passLibrary.passes()
    }
    
    // 패스 추가
    func addPass(_ pass: PKPass) throws {
        try passLibrary.addPasses([pass])
    }
    
    // 패스 제거
    func removePass(_ pass: PKPass) {
        passLibrary.removePass(pass)
    }
}

// 01-05-contains-pass.swift
extension PassManager {
    func containsPass(
        passTypeIdentifier: String,
        serialNumber: String
    ) -> Bool {
        return passLibrary.containsPass(
            PKPass.self,
            passTypeIdentifier: passTypeIdentifier,
            serialNumber: serialNumber
        )
    }
}

// 01-06-apple-pay-check.swift
func checkApplePaySupport() -> (canPay: Bool, hasCards: Bool) {
    let canPay = PKPaymentAuthorizationController.canMakePayments()
    let hasCards = PKPaymentAuthorizationController.canMakePayments(
        usingNetworks: [.visa, .masterCard, .amex]
    )
    return (canPay, hasCards)
}

// 01-07-payment-button.swift
struct ApplePayButtonView: View {
    var body: some View {
        PaymentButton(.buy, action: startPayment)
            .frame(height: 50)
            .padding()
    }
    
    private func startPayment() {
        // 결제 시작 로직
    }
}
