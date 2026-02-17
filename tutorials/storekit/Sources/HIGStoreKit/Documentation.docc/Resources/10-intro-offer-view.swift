import SwiftUI
import StoreKit

/// Introductory Offer를 표시하는 페이월 뷰
struct IntroOfferView: View {
    let product: Product
    let isEligible: Bool
    let onPurchase: () async -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 상품 정보
            Text(product.displayName)
                .font(.title2.bold())
            
            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 오퍼 배지
            if isEligible, let intro = product.subscription?.introductoryOffer {
                IntroOfferBadge(offer: intro)
            }
            
            // 가격 정보
            PriceSection(product: product, isEligible: isEligible)
            
            // 구독 버튼
            Button {
                Task { await onPurchase() }
            } label: {
                Text(buttonTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // HIG: 오퍼 종료 후 가격 안내
            if isEligible {
                Text("체험 종료 후 \(product.displayPrice)/월이 청구됩니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    private var buttonTitle: String {
        if isEligible, let intro = product.subscription?.introductoryOffer {
            switch intro.paymentMode {
            case .freeTrial:
                return "무료 체험 시작하기"
            case .payAsYouGo, .payUpFront:
                return "\(intro.displayPrice)에 시작하기"
            @unknown default:
                return "구독하기"
            }
        }
        return "\(product.displayPrice)에 구독하기"
    }
}

struct IntroOfferBadge: View {
    let offer: Product.SubscriptionOffer
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
            Text(badgeText)
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.15))
        .foregroundStyle(.green)
        .clipShape(Capsule())
    }
    
    private var iconName: String {
        switch offer.paymentMode {
        case .freeTrial: return "gift"
        case .payAsYouGo: return "tag"
        case .payUpFront: return "creditcard"
        @unknown default: return "star"
        }
    }
    
    private var badgeText: String {
        switch offer.paymentMode {
        case .freeTrial:
            return "\(offer.period.value)일 무료 체험"
        case .payAsYouGo:
            return "\(offer.periodCount)회 \(offer.displayPrice)"
        case .payUpFront:
            return "\(offer.displayPrice) 선불 할인"
        @unknown default:
            return "특별 오퍼"
        }
    }
}

struct PriceSection: View {
    let product: Product
    let isEligible: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            if isEligible, let intro = product.subscription?.introductoryOffer {
                // 할인 가격 강조
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(intro.displayPrice)
                        .font(.largeTitle.bold())
                    if intro.paymentMode != .freeTrial {
                        Text("/ \(intro.period.unit.localizedDescription)")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 정상 가격 취소선
                Text("정상가 \(product.displayPrice)")
                    .font(.subheadline)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            } else {
                // 정상 가격 표시
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(product.displayPrice)
                        .font(.largeTitle.bold())
                    Text("/ 월")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
