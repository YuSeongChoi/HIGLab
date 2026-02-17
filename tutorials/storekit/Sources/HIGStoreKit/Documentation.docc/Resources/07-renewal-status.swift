import SwiftUI
import StoreKit

/// 구독 갱신 상태 뷰
struct RenewalStatusView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var renewalState: Product.SubscriptionInfo.RenewalState?
    @State private var renewalInfo: Product.SubscriptionInfo.RenewalInfo?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 갱신 상태
            HStack {
                statusIcon
                VStack(alignment: .leading) {
                    Text(statusTitle)
                        .font(.headline)
                    Text(statusDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 만료일 정보
            if let expirationDate = subscriptionManager.expirationDate {
                HStack {
                    Image(systemName: "calendar")
                    Text(renewalState == .willRenew ? "다음 갱신일" : "만료일")
                    Spacer()
                    Text(expirationDate, style: .date)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 갱신 해제 시 안내
            if renewalState == .expired || renewalState == .revoked {
                Button("다시 구독하기") {
                    // 재구독 플로우
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            await loadRenewalStatus()
        }
    }
    
    private var statusIcon: some View {
        Group {
            switch renewalState {
            case .willRenew:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .expired:
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            case .inBillingRetry:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            default:
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.title)
    }
    
    private var statusTitle: String {
        switch renewalState {
        case .willRenew: return "활성 구독"
        case .expired: return "만료됨"
        case .inBillingRetry: return "결제 재시도 중"
        case .inGracePeriod: return "유예 기간"
        case .revoked: return "취소됨"
        default: return "알 수 없음"
        }
    }
    
    private var statusDescription: String {
        switch renewalState {
        case .willRenew: return "자동으로 갱신됩니다"
        case .expired: return "구독이 만료되었습니다"
        case .inBillingRetry: return "결제 정보를 확인해주세요"
        case .inGracePeriod: return "서비스가 곧 중단됩니다"
        case .revoked: return "환불 처리되었습니다"
        default: return ""
        }
    }
    
    private func loadRenewalStatus() async {
        guard let productID = subscriptionManager.activeTransaction?.productID,
              let product = try? await Product.products(for: [productID]).first,
              let subscription = product.subscription else {
            return
        }
        
        let statuses = try? await subscription.status
        if let status = statuses?.first {
            self.renewalState = status.state
        }
    }
}
