import StoreKit

/// Promotional Offer 관리
@MainActor
class PromoOfferManager: ObservableObject {
    @Published var availableOffers: [PromoOfferInfo] = []
    @Published var isLoading = false
    
    /// 상품의 Promotional Offer 목록 로딩
    func loadPromotionalOffers(for product: Product) async {
        isLoading = true
        defer { isLoading = false }
        
        guard product.type == .autoRenewable,
              let subscription = product.subscription else {
            return
        }
        
        // 프로모션 오퍼 목록 확인
        let offers = subscription.promotionalOffers
        
        availableOffers = offers.map { offer in
            PromoOfferInfo(
                id: offer.id,
                type: offer.type,
                displayPrice: offer.displayPrice,
                period: offer.period,
                periodCount: offer.periodCount,
                paymentMode: offer.paymentMode
            )
        }
        
        for offer in offers {
            print("📦 프로모션 오퍼: \(offer.id)")
            print("   - 유형: \(offer.type)")
            print("   - 가격: \(offer.displayPrice)")
            print("   - 기간: \(offer.period.value) \(offer.period.unit)")
        }
    }
    
    /// 특정 사용자에게 오퍼를 표시할지 결정
    /// 비즈니스 로직에 따라 커스터마이즈
    func shouldShowOffer(
        offerId: String,
        subscriptionStatus: Product.SubscriptionInfo.Status?
    ) -> Bool {
        guard let status = subscriptionStatus else {
            // 구독 상태 없음 → 이탈 사용자, 윈백 오퍼 표시
            return true
        }
        
        switch status.state {
        case .subscribed:
            // 현재 구독 중 → 업그레이드 오퍼만 표시
            return false
        case .expired:
            // 만료됨 → 윈백 오퍼 표시
            return true
        case .inBillingRetryPeriod:
            // 결제 재시도 중 → 리텐션 오퍼 표시
            return true
        case .inGracePeriod:
            // 유예 기간 → 리텐션 오퍼 표시
            return true
        case .revoked:
            // 취소/환불됨 → 윈백 오퍼 표시
            return true
        default:
            return false
        }
    }
}

struct PromoOfferInfo: Identifiable {
    let id: String
    let type: Product.SubscriptionOffer.OfferType
    let displayPrice: String
    let period: Product.SubscriptionPeriod
    let periodCount: Int
    let paymentMode: Product.SubscriptionOffer.PaymentMode
    
    var description: String {
        switch paymentMode {
        case .freeTrial:
            return "\(period.value)일 무료"
        case .payAsYouGo:
            return "\(periodCount)회 \(displayPrice)"
        case .payUpFront:
            return "\(displayPrice) 선불"
        @unknown default:
            return displayPrice
        }
    }
}
