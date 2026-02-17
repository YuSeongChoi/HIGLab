import StoreKit

/// Introductory Offer 자격 확인 및 관리
@MainActor
class IntroOfferManager: ObservableObject {
    @Published var eligibleProducts: [Product] = []
    @Published var isLoading = false
    
    /// 구독 그룹별 Introductory Offer 자격 확인
    func checkEligibility(for products: [Product]) async {
        isLoading = true
        defer { isLoading = false }
        
        var eligible: [Product] = []
        
        for product in products {
            // 자동 갱신 구독 상품만 체크
            guard product.type == .autoRenewable else { continue }
            
            // Introductory Offer 존재 여부 확인
            guard let introOffer = product.subscription?.introductoryOffer else {
                continue
            }
            
            // 자격 확인 (구독 그룹당 한 번만 가능)
            let isEligible = await product.subscription?.isEligibleForIntroOffer ?? false
            
            if isEligible {
                eligible.append(product)
                print("✅ \(product.displayName): 소개 오퍼 자격 있음")
                print("   - 유형: \(introOffer.paymentMode.description)")
                print("   - 기간: \(introOffer.period.debugDescription)")
            } else {
                print("❌ \(product.displayName): 소개 오퍼 자격 없음")
            }
        }
        
        eligibleProducts = eligible
    }
    
    /// Introductory Offer 상세 정보 포맷팅
    func formatIntroOffer(for product: Product) -> IntroOfferInfo? {
        guard let intro = product.subscription?.introductoryOffer else {
            return nil
        }
        
        let description: String
        switch intro.paymentMode {
        case .freeTrial:
            description = "\(intro.period.value)일 무료 체험"
        case .payAsYouGo:
            description = "\(intro.displayPrice)로 \(intro.periodCount)회"
        case .payUpFront:
            description = "\(intro.displayPrice) 선불"
        @unknown default:
            description = "특별 오퍼"
        }
        
        return IntroOfferInfo(
            type: intro.paymentMode,
            description: description,
            originalPrice: product.displayPrice,
            offerPrice: intro.displayPrice,
            duration: intro.period
        )
    }
}

struct IntroOfferInfo {
    let type: Product.SubscriptionOffer.PaymentMode
    let description: String
    let originalPrice: String
    let offerPrice: String
    let duration: Product.SubscriptionPeriod
}

extension Product.SubscriptionOffer.PaymentMode {
    var description: String {
        switch self {
        case .freeTrial: return "무료 체험"
        case .payAsYouGo: return "할인 결제"
        case .payUpFront: return "선불 할인"
        @unknown default: return "특별 오퍼"
        }
    }
}
