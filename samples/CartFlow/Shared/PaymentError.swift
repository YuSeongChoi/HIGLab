import Foundation
import PassKit

// MARK: - 결제 오류
/// Apple Pay 결제 과정에서 발생할 수 있는 모든 오류 유형
///
/// ## 오류 카테고리
/// - **구성 오류**: Merchant ID 누락, 잘못된 설정 등
/// - **권한 오류**: Apple Pay 미지원, 카드 미등록 등
/// - **결제 오류**: 사용자 취소, 결제 실패 등
/// - **네트워크 오류**: 서버 통신 실패
/// - **검증 오류**: 데이터 유효성 검사 실패

enum PaymentError: Error, Sendable {
    
    // MARK: - 구성 오류 (Configuration Errors)
    
    /// Merchant Identifier가 설정되지 않음
    case merchantIdentifierNotConfigured
    
    /// 지원하는 카드 네트워크가 없음
    case noSupportedNetworks
    
    /// 잘못된 통화 코드
    case invalidCurrencyCode(String)
    
    /// 잘못된 국가 코드
    case invalidCountryCode(String)
    
    /// 결제 금액이 유효하지 않음
    case invalidAmount(Decimal)
    
    /// 결제 항목이 비어있음
    case emptyPaymentItems
    
    // MARK: - 권한 오류 (Authorization Errors)
    
    /// 기기에서 Apple Pay를 지원하지 않음
    case applePayNotSupported
    
    /// 지원하는 네트워크의 카드가 등록되지 않음
    case noRegisteredCards
    
    /// Apple Pay 설정이 필요함
    case applePaySetupRequired
    
    /// 결제 권한이 거부됨 (Parental Controls 등)
    case authorizationDenied
    
    // MARK: - 결제 처리 오류 (Payment Processing Errors)
    
    /// 사용자가 결제를 취소함
    case userCancelled
    
    /// 결제 승인 실패
    case authorizationFailed(underlyingError: Error?)
    
    /// 결제 토큰 생성 실패
    case tokenGenerationFailed
    
    /// 결제 처리 타임아웃
    case timeout
    
    /// 결제 세션이 만료됨
    case sessionExpired
    
    /// 중복 결제 시도
    case duplicatePayment
    
    // MARK: - 네트워크 오류 (Network Errors)
    
    /// 네트워크 연결 없음
    case noNetworkConnection
    
    /// 서버 응답 오류
    case serverError(statusCode: Int, message: String?)
    
    /// 서버 응답 파싱 실패
    case invalidServerResponse
    
    /// SSL/TLS 인증서 오류
    case sslError
    
    // MARK: - 검증 오류 (Validation Errors)
    
    /// 배송 주소가 유효하지 않음
    case invalidShippingAddress(reason: String?)
    
    /// 청구 주소가 유효하지 않음
    case invalidBillingAddress(reason: String?)
    
    /// 연락처 정보가 유효하지 않음
    case invalidContactInfo(field: String)
    
    /// 선택된 배송 방법이 유효하지 않음
    case invalidShippingMethod
    
    /// 쿠폰 코드가 유효하지 않음
    case invalidCouponCode(String)
    
    /// 쿠폰이 만료됨
    case couponExpired(String)
    
    // MARK: - 재고/상품 오류 (Inventory Errors)
    
    /// 재고 부족
    case insufficientStock(productId: String, available: Int, requested: Int)
    
    /// 상품을 찾을 수 없음
    case productNotFound(productId: String)
    
    /// 상품 가격이 변경됨
    case priceChanged(productId: String, oldPrice: Int, newPrice: Int)
    
    // MARK: - 기타 오류
    
    /// 알 수 없는 오류
    case unknown(underlyingError: Error?)
    
    /// 시스템 오류
    case systemError(String)
}

// MARK: - LocalizedError

extension PaymentError: LocalizedError {
    
    /// 사용자에게 표시할 오류 설명
    var errorDescription: String? {
        switch self {
        // 구성 오류
        case .merchantIdentifierNotConfigured:
            return "결제 설정이 완료되지 않았습니다. 앱 설정을 확인해주세요."
        case .noSupportedNetworks:
            return "지원하는 결제 수단이 없습니다."
        case .invalidCurrencyCode(let code):
            return "지원하지 않는 통화입니다: \(code)"
        case .invalidCountryCode(let code):
            return "지원하지 않는 국가입니다: \(code)"
        case .invalidAmount(let amount):
            return "결제 금액이 올바르지 않습니다: \(amount)"
        case .emptyPaymentItems:
            return "결제할 항목이 없습니다."
            
        // 권한 오류
        case .applePayNotSupported:
            return "이 기기에서는 Apple Pay를 사용할 수 없습니다."
        case .noRegisteredCards:
            return "등록된 결제 카드가 없습니다. Wallet 앱에서 카드를 추가해주세요."
        case .applePaySetupRequired:
            return "Apple Pay 설정이 필요합니다."
        case .authorizationDenied:
            return "결제 권한이 거부되었습니다."
            
        // 결제 처리 오류
        case .userCancelled:
            return "결제가 취소되었습니다."
        case .authorizationFailed(let error):
            if let error = error {
                return "결제 승인에 실패했습니다: \(error.localizedDescription)"
            }
            return "결제 승인에 실패했습니다."
        case .tokenGenerationFailed:
            return "결제 정보 처리 중 오류가 발생했습니다."
        case .timeout:
            return "결제 처리 시간이 초과되었습니다. 다시 시도해주세요."
        case .sessionExpired:
            return "결제 세션이 만료되었습니다. 다시 시도해주세요."
        case .duplicatePayment:
            return "이미 결제가 진행 중입니다."
            
        // 네트워크 오류
        case .noNetworkConnection:
            return "인터넷 연결을 확인해주세요."
        case .serverError(let statusCode, let message):
            if let message = message {
                return "서버 오류 (\(statusCode)): \(message)"
            }
            return "서버 오류가 발생했습니다. (코드: \(statusCode))"
        case .invalidServerResponse:
            return "서버 응답을 처리할 수 없습니다."
        case .sslError:
            return "보안 연결에 문제가 있습니다."
            
        // 검증 오류
        case .invalidShippingAddress(let reason):
            if let reason = reason {
                return "배송 주소 오류: \(reason)"
            }
            return "배송 주소가 올바르지 않습니다."
        case .invalidBillingAddress(let reason):
            if let reason = reason {
                return "청구 주소 오류: \(reason)"
            }
            return "청구 주소가 올바르지 않습니다."
        case .invalidContactInfo(let field):
            return "연락처 정보가 올바르지 않습니다: \(field)"
        case .invalidShippingMethod:
            return "선택한 배송 방법을 사용할 수 없습니다."
        case .invalidCouponCode(let code):
            return "유효하지 않은 쿠폰 코드입니다: \(code)"
        case .couponExpired(let code):
            return "만료된 쿠폰입니다: \(code)"
            
        // 재고/상품 오류
        case .insufficientStock(_, let available, let requested):
            return "재고가 부족합니다. (요청: \(requested)개, 가능: \(available)개)"
        case .productNotFound:
            return "상품을 찾을 수 없습니다."
        case .priceChanged(_, let oldPrice, let newPrice):
            return "상품 가격이 변경되었습니다. (₩\(oldPrice.formatted()) → ₩\(newPrice.formatted()))"
            
        // 기타
        case .unknown(let error):
            if let error = error {
                return "오류가 발생했습니다: \(error.localizedDescription)"
            }
            return "알 수 없는 오류가 발생했습니다."
        case .systemError(let message):
            return "시스템 오류: \(message)"
        }
    }
    
    /// 오류 복구 제안
    var recoverySuggestion: String? {
        switch self {
        case .merchantIdentifierNotConfigured, .noSupportedNetworks:
            return "개발자에게 문의해주세요."
        case .applePayNotSupported:
            return "다른 결제 수단을 이용해주세요."
        case .noRegisteredCards, .applePaySetupRequired:
            return "설정 > Wallet & Apple Pay에서 카드를 추가해주세요."
        case .userCancelled:
            return nil
        case .timeout, .noNetworkConnection:
            return "인터넷 연결을 확인하고 다시 시도해주세요."
        case .insufficientStock:
            return "수량을 줄이거나 다른 상품을 선택해주세요."
        case .priceChanged:
            return "장바구니를 새로고침 해주세요."
        default:
            return "잠시 후 다시 시도해주세요."
        }
    }
    
    /// 도움말 앵커 (문서 링크용)
    var helpAnchor: String? {
        switch self {
        case .applePayNotSupported, .noRegisteredCards, .applePaySetupRequired:
            return "apple-pay-setup"
        case .noNetworkConnection:
            return "network-troubleshooting"
        default:
            return nil
        }
    }
}

// MARK: - 오류 분류

extension PaymentError {
    
    /// 오류 카테고리
    enum Category: String, Sendable {
        case configuration = "설정 오류"
        case authorization = "권한 오류"
        case payment = "결제 오류"
        case network = "네트워크 오류"
        case validation = "검증 오류"
        case inventory = "재고 오류"
        case other = "기타 오류"
    }
    
    /// 현재 오류의 카테고리
    var category: Category {
        switch self {
        case .merchantIdentifierNotConfigured, .noSupportedNetworks,
             .invalidCurrencyCode, .invalidCountryCode, .invalidAmount,
             .emptyPaymentItems:
            return .configuration
        case .applePayNotSupported, .noRegisteredCards, .applePaySetupRequired,
             .authorizationDenied:
            return .authorization
        case .userCancelled, .authorizationFailed, .tokenGenerationFailed,
             .timeout, .sessionExpired, .duplicatePayment:
            return .payment
        case .noNetworkConnection, .serverError, .invalidServerResponse, .sslError:
            return .network
        case .invalidShippingAddress, .invalidBillingAddress, .invalidContactInfo,
             .invalidShippingMethod, .invalidCouponCode, .couponExpired:
            return .validation
        case .insufficientStock, .productNotFound, .priceChanged:
            return .inventory
        case .unknown, .systemError:
            return .other
        }
    }
    
    /// 재시도 가능 여부
    var isRetryable: Bool {
        switch self {
        case .timeout, .noNetworkConnection, .serverError, .sessionExpired:
            return true
        case .userCancelled, .applePayNotSupported, .merchantIdentifierNotConfigured:
            return false
        default:
            return false
        }
    }
    
    /// 사용자 입력으로 해결 가능한지 여부
    var isUserRecoverable: Bool {
        switch self {
        case .noRegisteredCards, .applePaySetupRequired, .invalidShippingAddress,
             .invalidBillingAddress, .invalidContactInfo, .invalidCouponCode,
             .insufficientStock:
            return true
        default:
            return false
        }
    }
    
    /// 로깅 심각도
    enum Severity: String {
        case info
        case warning
        case error
        case critical
    }
    
    var severity: Severity {
        switch self {
        case .userCancelled:
            return .info
        case .invalidCouponCode, .couponExpired, .insufficientStock:
            return .warning
        case .merchantIdentifierNotConfigured, .noSupportedNetworks, .sslError:
            return .critical
        default:
            return .error
        }
    }
}

// MARK: - PKPaymentAuthorizationResult 변환

extension PaymentError {
    
    /// PKPaymentAuthorizationResult 에러 배열로 변환
    /// - Returns: Apple Pay 결제 시트에 표시할 에러 배열
    func toPKPaymentErrors() -> [Error] {
        switch self {
        case .invalidShippingAddress(let reason):
            let error = PKPaymentRequest.paymentShippingAddressInvalidError(
                withKey: CNPostalAddressStreetKey,
                localizedDescription: reason ?? "배송 주소가 올바르지 않습니다."
            )
            return [error]
            
        case .invalidBillingAddress(let reason):
            let error = PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: CNPostalAddressStreetKey,
                localizedDescription: reason ?? "청구 주소가 올바르지 않습니다."
            )
            return [error]
            
        case .invalidContactInfo(let field):
            let key: String
            switch field {
            case "phone", "전화번호":
                key = CNContactPhoneNumbersKey
            case "email", "이메일":
                key = CNContactEmailAddressesKey
            case "name", "이름":
                key = CNContactGivenNameKey
            default:
                key = field
            }
            let error = PKPaymentRequest.paymentShippingAddressInvalidError(
                withKey: key,
                localizedDescription: "연락처 정보를 확인해주세요: \(field)"
            )
            return [error]
            
        case .invalidCouponCode(let code):
            let error = PKPaymentRequest.paymentCouponCodeInvalidError(
                localizedDescription: "유효하지 않은 쿠폰입니다: \(code)"
            )
            return [error]
            
        case .couponExpired(let code):
            let error = PKPaymentRequest.paymentCouponCodeExpiredError(
                localizedDescription: "만료된 쿠폰입니다: \(code)"
            )
            return [error]
            
        default:
            return []
        }
    }
}

// MARK: - Contacts Framework Import

import Contacts

// MARK: - CustomNSError

extension PaymentError: CustomNSError {
    
    static var errorDomain: String {
        "com.cartflow.payment"
    }
    
    var errorCode: Int {
        switch self {
        // 구성 오류: 1000번대
        case .merchantIdentifierNotConfigured: return 1001
        case .noSupportedNetworks: return 1002
        case .invalidCurrencyCode: return 1003
        case .invalidCountryCode: return 1004
        case .invalidAmount: return 1005
        case .emptyPaymentItems: return 1006
            
        // 권한 오류: 2000번대
        case .applePayNotSupported: return 2001
        case .noRegisteredCards: return 2002
        case .applePaySetupRequired: return 2003
        case .authorizationDenied: return 2004
            
        // 결제 처리 오류: 3000번대
        case .userCancelled: return 3001
        case .authorizationFailed: return 3002
        case .tokenGenerationFailed: return 3003
        case .timeout: return 3004
        case .sessionExpired: return 3005
        case .duplicatePayment: return 3006
            
        // 네트워크 오류: 4000번대
        case .noNetworkConnection: return 4001
        case .serverError: return 4002
        case .invalidServerResponse: return 4003
        case .sslError: return 4004
            
        // 검증 오류: 5000번대
        case .invalidShippingAddress: return 5001
        case .invalidBillingAddress: return 5002
        case .invalidContactInfo: return 5003
        case .invalidShippingMethod: return 5004
        case .invalidCouponCode: return 5005
        case .couponExpired: return 5006
            
        // 재고 오류: 6000번대
        case .insufficientStock: return 6001
        case .productNotFound: return 6002
        case .priceChanged: return 6003
            
        // 기타: 9000번대
        case .unknown: return 9001
        case .systemError: return 9002
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: errorDescription ?? "Unknown error"
        ]
        
        if let suggestion = recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = suggestion
        }
        
        if let anchor = helpAnchor {
            userInfo[NSHelpAnchorErrorKey] = anchor
        }
        
        // 추가 컨텍스트 정보
        switch self {
        case .serverError(let statusCode, _):
            userInfo["HTTPStatusCode"] = statusCode
        case .insufficientStock(let productId, let available, let requested):
            userInfo["ProductID"] = productId
            userInfo["AvailableStock"] = available
            userInfo["RequestedQuantity"] = requested
        case .priceChanged(let productId, let oldPrice, let newPrice):
            userInfo["ProductID"] = productId
            userInfo["OldPrice"] = oldPrice
            userInfo["NewPrice"] = newPrice
        default:
            break
        }
        
        return userInfo
    }
}

// MARK: - Equatable

extension PaymentError: Equatable {
    static func == (lhs: PaymentError, rhs: PaymentError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
