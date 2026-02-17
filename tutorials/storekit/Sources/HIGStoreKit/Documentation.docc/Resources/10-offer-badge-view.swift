import SwiftUI
import StoreKit

/// HIG 가이드라인을 준수하는 오퍼 배지 컴포넌트
struct HIGOfferBadge: View {
    let offerType: OfferType
    let originalPrice: String
    let offerPrice: String
    let duration: String
    let afterOfferPrice: String
    
    enum OfferType {
        case freeTrial
        case introductory
        case promotional
        case offerCode
        
        var icon: String {
            switch self {
            case .freeTrial: return "gift.fill"
            case .introductory: return "sparkles"
            case .promotional: return "tag.fill"
            case .offerCode: return "ticket.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .freeTrial: return .green
            case .introductory: return .blue
            case .promotional: return .orange
            case .offerCode: return .purple
            }
        }
        
        var title: String {
            switch self {
            case .freeTrial: return "무료 체험"
            case .introductory: return "첫 구독 할인"
            case .promotional: return "특별 할인"
            case .offerCode: return "프로모션 코드"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 배지 헤더
            HStack {
                Image(systemName: offerType.icon)
                Text(offerType.title)
                    .font(.headline)
            }
            .foregroundStyle(offerType.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(offerType.color.opacity(0.15))
            .clipShape(Capsule())
            
            // 가격 비교
            VStack(spacing: 8) {
                // 할인 가격 (강조)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(offerPrice)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("/ \(duration)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 정상 가격 (취소선)
                Text("정상가 \(originalPrice)")
                    .font(.subheadline)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // HIG 필수: 오퍼 종료 후 가격 안내
            VStack(spacing: 4) {
                Text("체험 종료 후")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(afterOfferPrice)/월 자동 갱신")
                    .font(.footnote.bold())
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - 오퍼 카드 (페이월용)

struct OfferCard: View {
    let product: Product
    let offer: Product.SubscriptionOffer?
    let isEligible: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // 상단: 오퍼 배지
                if isEligible, let offer = offer {
                    HStack {
                        Spacer()
                        OfferTypeBadge(paymentMode: offer.paymentMode)
                    }
                }
                
                // 상품명
                Text(product.displayName)
                    .font(.headline)
                
                // 가격 정보
                if isEligible, let offer = offer {
                    // 오퍼 가격
                    Text(offer.displayPrice)
                        .font(.title.bold())
                    
                    Text("이후 \(product.displayPrice)/월")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    // 정상 가격
                    Text(product.displayPrice)
                        .font(.title.bold())
                    
                    Text("/ 월")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct OfferTypeBadge: View {
    let paymentMode: Product.SubscriptionOffer.PaymentMode
    
    var body: some View {
        Text(badgeText)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
    
    private var badgeText: String {
        switch paymentMode {
        case .freeTrial: return "무료 체험"
        case .payAsYouGo: return "할인"
        case .payUpFront: return "선불 할인"
        @unknown default: return "특별 오퍼"
        }
    }
    
    private var badgeColor: Color {
        switch paymentMode {
        case .freeTrial: return .green
        case .payAsYouGo: return .orange
        case .payUpFront: return .blue
        @unknown default: return .purple
        }
    }
}

// MARK: - Previews

#Preview("HIG 오퍼 배지") {
    VStack(spacing: 20) {
        HIGOfferBadge(
            offerType: .freeTrial,
            originalPrice: "₩11,000",
            offerPrice: "₩0",
            duration: "7일",
            afterOfferPrice: "₩11,000"
        )
        
        HIGOfferBadge(
            offerType: .promotional,
            originalPrice: "₩11,000",
            offerPrice: "₩5,500",
            duration: "첫 달",
            afterOfferPrice: "₩11,000"
        )
    }
    .padding()
    .background(Color(.systemGray5))
}
