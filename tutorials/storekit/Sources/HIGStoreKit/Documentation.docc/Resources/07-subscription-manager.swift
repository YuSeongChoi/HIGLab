import StoreKit

/// 구독 그룹과 레벨을 관리하는 매니저
@MainActor
class SubscriptionManager: ObservableObject {
    
    /// 구독 그룹 식별자
    static let subscriptionGroupID = "com.example.subscription.group"
    
    /// 서비스 레벨 정의 (높을수록 상위 플랜)
    enum ServiceLevel: Int, Comparable {
        case basic = 1
        case premium = 2
        case ultimate = 3
        
        static func < (lhs: ServiceLevel, rhs: ServiceLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    @Published var currentSubscription: Product.SubscriptionInfo?
    @Published var activeTransaction: Transaction?
    
    /// 상품 ID를 서비스 레벨로 매핑
    func serviceLevel(for productID: String) -> ServiceLevel {
        switch productID {
        case "com.example.basic.monthly", "com.example.basic.yearly":
            return .basic
        case "com.example.premium.monthly", "com.example.premium.yearly":
            return .premium
        case "com.example.ultimate.monthly", "com.example.ultimate.yearly":
            return .ultimate
        default:
            return .basic
        }
    }
    
    /// 현재 구독의 서비스 레벨 확인
    var currentServiceLevel: ServiceLevel? {
        guard let transaction = activeTransaction else { return nil }
        return serviceLevel(for: transaction.productID)
    }
}
