import StoreKit

extension SubscriptionManager {
    
    /// 현재 활성 구독 정보 로드
    func loadActiveSubscription() async {
        // 현재 유효한 권한 확인
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            // 구독 상품인 경우만 처리
            if transaction.productType == .autoRenewable {
                self.activeTransaction = transaction
                await loadSubscriptionInfo(for: transaction.productID)
                return
            }
        }
        
        // 활성 구독 없음
        self.activeTransaction = nil
        self.currentSubscription = nil
    }
    
    /// 구독 상세 정보 로드
    private func loadSubscriptionInfo(for productID: String) async {
        guard let product = try? await Product.products(for: [productID]).first,
              let subscriptionInfo = product.subscription else {
            return
        }
        
        self.currentSubscription = subscriptionInfo
    }
    
    /// 구독 만료 예정일
    var expirationDate: Date? {
        activeTransaction?.expirationDate
    }
    
    /// 다음 갱신까지 남은 일수
    var daysUntilRenewal: Int? {
        guard let expiration = expirationDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiration).day
        return max(0, days ?? 0)
    }
}
