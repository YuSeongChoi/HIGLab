import StoreKit

/// 사용자 권한을 관리하는 매니저
@MainActor
class EntitlementManager: ObservableObject {
    
    @Published var hasActiveSubscription = false
    @Published var ownershipType: Transaction.OwnershipType?
    @Published var premiumFeatures: Set<String> = []
    
    /// 현재 권한 로드
    func loadEntitlements() async {
        var activeSubscription: Transaction?
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            switch transaction.productType {
            case .autoRenewable:
                activeSubscription = transaction
                self.ownershipType = transaction.ownershipType
                
            case .nonConsumable:
                // 비소모성 상품은 기능 잠금 해제
                premiumFeatures.insert(transaction.productID)
                
            default:
                break
            }
        }
        
        self.hasActiveSubscription = activeSubscription != nil
    }
    
    /// 소유권 타입에 따른 권한 레벨
    var accessLevel: AccessLevel {
        guard hasActiveSubscription else { return .free }
        
        switch ownershipType {
        case .purchased:
            return .fullAccess
        case .familyShared:
            return .familyAccess
        default:
            return .free
        }
    }
    
    enum AccessLevel {
        case free
        case familyAccess    // 가족 공유 - 일부 기능 제한 가능
        case fullAccess      // 직접 구매 - 모든 기능
        
        var canManageSubscription: Bool {
            self == .fullAccess
        }
        
        var description: String {
            switch self {
            case .free: return "무료"
            case .familyAccess: return "가족 공유"
            case .fullAccess: return "프리미엄"
            }
        }
    }
}
