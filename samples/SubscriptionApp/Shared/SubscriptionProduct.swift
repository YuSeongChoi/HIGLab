import StoreKit

// MARK: - 구독 상품 정의
// 앱에서 제공하는 구독 상품 ID를 정의합니다.

/// 구독 상품 열거형
/// App Store Connect에서 설정한 Product ID와 일치해야 합니다.
enum SubscriptionProduct: String, CaseIterable, Identifiable {
    // MARK: - 구독 티어
    
    /// 월간 구독 (기본)
    case monthlyBasic = "com.higlab.subscription.monthly.basic"
    
    /// 월간 구독 (프리미엄)
    case monthlyPremium = "com.higlab.subscription.monthly.premium"
    
    /// 연간 구독 (기본)
    case yearlyBasic = "com.higlab.subscription.yearly.basic"
    
    /// 연간 구독 (프리미엄)
    case yearlyPremium = "com.higlab.subscription.yearly.premium"
    
    // MARK: - Identifiable
    
    var id: String { rawValue }
    
    // MARK: - 상품 정보
    
    /// 상품의 표시 이름
    var displayName: String {
        switch self {
        case .monthlyBasic:
            return "월간 기본"
        case .monthlyPremium:
            return "월간 프리미엄"
        case .yearlyBasic:
            return "연간 기본"
        case .yearlyPremium:
            return "연간 프리미엄"
        }
    }
    
    /// 상품 설명
    var description: String {
        switch self {
        case .monthlyBasic:
            return "기본 기능을 월 단위로 이용하세요"
        case .monthlyPremium:
            return "모든 프리미엄 기능을 월 단위로 이용하세요"
        case .yearlyBasic:
            return "기본 기능을 연 단위로 할인된 가격에 이용하세요"
        case .yearlyPremium:
            return "모든 프리미엄 기능을 연 단위로 할인된 가격에 이용하세요"
        }
    }
    
    /// 구독 티어 (기본 vs 프리미엄)
    var tier: SubscriptionTier {
        switch self {
        case .monthlyBasic, .yearlyBasic:
            return .basic
        case .monthlyPremium, .yearlyPremium:
            return .premium
        }
    }
    
    /// 구독 기간 (월간 vs 연간)
    var period: SubscriptionPeriod {
        switch self {
        case .monthlyBasic, .monthlyPremium:
            return .monthly
        case .yearlyBasic, .yearlyPremium:
            return .yearly
        }
    }
    
    /// 모든 상품 ID 배열
    static var allProductIDs: [String] {
        Self.allCases.map { $0.rawValue }
    }
    
    /// 구독 그룹 ID (App Store Connect에서 설정)
    static let groupID = "com.higlab.subscription.group"
}

// MARK: - 구독 티어

/// 구독 등급을 나타내는 열거형
enum SubscriptionTier: Int, Comparable {
    case none = 0      // 구독 없음
    case basic = 1     // 기본 구독
    case premium = 2   // 프리미엄 구독
    
    /// 티어 비교 연산자
    static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    /// 티어 표시 이름
    var displayName: String {
        switch self {
        case .none:
            return "무료"
        case .basic:
            return "기본"
        case .premium:
            return "프리미엄"
        }
    }
}

// MARK: - 구독 기간

/// 구독 기간을 나타내는 열거형
enum SubscriptionPeriod: String {
    case monthly = "월간"
    case yearly = "연간"
    
    /// 할인율 (연간 구독의 경우)
    var savingsPercentage: Int {
        switch self {
        case .monthly:
            return 0
        case .yearly:
            return 20 // 연간 구독 시 약 20% 할인
        }
    }
}
