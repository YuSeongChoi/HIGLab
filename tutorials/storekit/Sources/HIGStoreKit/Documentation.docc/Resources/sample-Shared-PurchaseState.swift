import Foundation

// MARK: - PurchaseState
/// 구매 진행 상태를 나타내는 열거형
/// UI에서 구매 버튼 상태 및 피드백을 제어하는 데 사용합니다.

enum PurchaseState: Equatable {
    /// 대기 상태 (구매 가능)
    case idle
    
    /// 구매 진행 중
    case purchasing
    
    /// 구매 성공
    case purchased
    
    /// 구매 실패
    case failed(Error)
    
    /// 사용자가 구매 취소
    case cancelled
    
    /// 보류 중 (승인 대기 - 가족 공유 등)
    case pending
    
    // MARK: - Equatable
    
    static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.purchasing, .purchasing),
             (.purchased, .purchased),
             (.cancelled, .cancelled),
             (.pending, .pending):
            return true
        case (.failed, .failed):
            // 에러 비교는 설명 문자열로 수행
            return true
        default:
            return false
        }
    }
}

// MARK: - 상태 속성
extension PurchaseState {
    /// 로딩 중인지 확인
    var isLoading: Bool {
        self == .purchasing
    }
    
    /// 성공 상태인지 확인
    var isSuccess: Bool {
        self == .purchased
    }
    
    /// 에러 메시지 (실패 시)
    var errorMessage: String? {
        if case .failed(let error) = self {
            return error.localizedDescription
        }
        return nil
    }
    
    /// 상태 설명 (한글)
    var description: String {
        switch self {
        case .idle:
            return "구매 가능"
        case .purchasing:
            return "구매 중..."
        case .purchased:
            return "구매 완료"
        case .failed(let error):
            return "구매 실패: \(error.localizedDescription)"
        case .cancelled:
            return "구매 취소됨"
        case .pending:
            return "승인 대기 중"
        }
    }
    
    /// SF Symbol 아이콘 이름
    var iconName: String {
        switch self {
        case .idle:
            return "cart"
        case .purchasing:
            return "arrow.clockwise"
        case .purchased:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        case .cancelled:
            return "xmark"
        case .pending:
            return "clock"
        }
    }
}

// MARK: - SubscriptionStatus
/// 구독 상태를 나타내는 열거형

enum SubscriptionStatus: Equatable {
    /// 활성 구독 중
    case active
    
    /// 만료됨
    case expired
    
    /// 갱신 예정
    case willRenew
    
    /// 갱신 취소됨 (기간 종료 후 만료 예정)
    case willExpire
    
    /// 환불됨
    case revoked
    
    /// 청구 문제로 유예 중
    case inGracePeriod
    
    /// 청구 재시도 중
    case inBillingRetry
    
    /// 구독 없음
    case none
    
    /// 상태 설명 (한글)
    var description: String {
        switch self {
        case .active:
            return "구독 중"
        case .expired:
            return "만료됨"
        case .willRenew:
            return "갱신 예정"
        case .willExpire:
            return "만료 예정"
        case .revoked:
            return "환불됨"
        case .inGracePeriod:
            return "유예 기간"
        case .inBillingRetry:
            return "결제 재시도 중"
        case .none:
            return "구독 없음"
        }
    }
    
    /// 구독이 유효한지 (기능 사용 가능 여부)
    var isEntitled: Bool {
        switch self {
        case .active, .willRenew, .willExpire, .inGracePeriod, .inBillingRetry:
            return true
        case .expired, .revoked, .none:
            return false
        }
    }
}

// MARK: - PurchaseError
/// 구매 관련 커스텀 에러

enum PurchaseError: LocalizedError {
    /// 상품을 찾을 수 없음
    case productNotFound
    
    /// 구매 확인 실패
    case verificationFailed
    
    /// 네트워크 오류
    case networkError
    
    /// 알 수 없는 오류
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "상품을 찾을 수 없습니다."
        case .verificationFailed:
            return "구매 확인에 실패했습니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
