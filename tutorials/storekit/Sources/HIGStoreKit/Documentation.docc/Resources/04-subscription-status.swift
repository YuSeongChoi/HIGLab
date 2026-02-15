import StoreKit

extension StoreManager {
    
    // MARK: - 구독 상태 확인
    
    func checkSubscriptionStatus() async -> SubscriptionStatus? {
        // 모든 현재 권한 확인
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            // 구독 상품만 필터
            if transaction.productType == .autoRenewable {
                return SubscriptionStatus(
                    isActive: true,
                    productID: transaction.productID,
                    expirationDate: transaction.expirationDate,
                    willAutoRenew: transaction.revocationDate == nil
                )
            }
        }
        
        return nil
    }
}

struct SubscriptionStatus {
    let isActive: Bool
    let productID: String
    let expirationDate: Date?
    let willAutoRenew: Bool
    
    var daysRemaining: Int? {
        guard let expiration = expirationDate else { return nil }
        return Calendar.current.dateComponents(
            [.day], from: Date(), to: expiration
        ).day
    }
}
