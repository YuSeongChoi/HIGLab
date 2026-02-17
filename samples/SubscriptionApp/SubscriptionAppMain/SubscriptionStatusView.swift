import SwiftUI
import StoreKit

// MARK: - 구독 상태 뷰
// 현재 구독의 상세 상태를 표시합니다.

struct SubscriptionStatusView: View {
    
    // MARK: - 환경 객체
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    // MARK: - 상태
    
    /// 구독 상태 정보
    @State private var subscriptionStatus: Product.SubscriptionInfo.Status?
    
    /// 로딩 중 여부
    @State private var isLoading = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            // 현재 구독 섹션
            currentSubscriptionSection
            
            // 자격 정보 섹션
            entitlementSection
            
            // 구독 상세 정보 섹션
            if subscriptionStatus != nil {
                subscriptionDetailsSection
            }
            
            // 문제 해결 섹션
            troubleshootingSection
        }
        .navigationTitle("구독 상태")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await refreshStatus()
        }
        .task {
            await loadSubscriptionStatus()
        }
    }
    
    // MARK: - 현재 구독 섹션
    
    private var currentSubscriptionSection: some View {
        Section {
            if let product = subscriptionManager.activeSubscription {
                // 활성 구독 있음
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.displayName)
                            .font(.headline)
                        
                        Text(product.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(product.displayPrice)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("/\(product.periodDescription ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 상태 배지
                HStack {
                    Label {
                        Text("활성")
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Text(entitlementManager.currentTier.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tierColor.opacity(0.1))
                        .foregroundColor(tierColor)
                        .cornerRadius(8)
                }
            } else {
                // 구독 없음
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("구독 없음")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("프리미엄 기능을 이용하려면 구독을 시작하세요.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("현재 구독")
        }
    }
    
    /// 티어에 따른 색상
    private var tierColor: Color {
        switch entitlementManager.currentTier {
        case .none:
            return .gray
        case .basic:
            return .blue
        case .premium:
            return .purple
        }
    }
    
    // MARK: - 자격 정보 섹션
    
    private var entitlementSection: some View {
        Section {
            // 현재 티어
            HStack {
                Text("구독 등급")
                Spacer()
                Text(entitlementManager.currentTier.displayName)
                    .foregroundColor(.secondary)
            }
            
            // 잠금 해제된 기능 수
            HStack {
                Text("이용 가능 기능")
                Spacer()
                Text("\(entitlementManager.unlockedFeatures.count)/\(Feature.allCases.count)")
                    .foregroundColor(.secondary)
            }
            
            // 기능 목록 (확장 가능)
            DisclosureGroup("기능 상세") {
                ForEach(Feature.allCases) { feature in
                    HStack {
                        Image(systemName: feature.icon)
                            .foregroundColor(entitlementManager.hasAccess(to: feature) ? .blue : .gray)
                            .frame(width: 24)
                        
                        Text(feature.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        if entitlementManager.hasAccess(to: feature) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Text(feature.requiredTier.displayName)
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        } header: {
            Text("자격 정보")
        }
    }
    
    // MARK: - 구독 상세 정보 섹션
    
    private var subscriptionDetailsSection: some View {
        Section {
            if let status = subscriptionStatus {
                // 갱신 상태
                if let renewalState = status.state {
                    HStack {
                        Text("갱신 상태")
                        Spacer()
                        Text(renewalStateText(renewalState))
                            .foregroundColor(renewalStateColor(renewalState))
                    }
                }
                
                // 만료일/다음 갱신일
                if let transaction = status.transaction,
                   case .verified(let verifiedTransaction) = transaction {
                    if let expirationDate = verifiedTransaction.expirationDate {
                        HStack {
                            Text(status.state == .expired ? "만료일" : "다음 갱신일")
                            Spacer()
                            Text(expirationDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 원래 구매일
                    HStack {
                        Text("최초 구매일")
                        Spacer()
                        Text(verifiedTransaction.originalPurchaseDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 갱신 정보
                if let renewalInfo = status.renewalInfo,
                   case .verified(let info) = renewalInfo {
                    // 자동 갱신 여부
                    HStack {
                        Text("자동 갱신")
                        Spacer()
                        Text(info.willAutoRenew ? "활성화" : "비활성화")
                            .foregroundColor(info.willAutoRenew ? .green : .orange)
                    }
                    
                    // 갱신될 상품 (업그레이드/다운그레이드 예정인 경우)
                    if let autoRenewProductId = info.autoRenewPreference,
                       autoRenewProductId != subscriptionManager.activeSubscription?.id {
                        HStack {
                            Text("다음 갱신 상품")
                            Spacer()
                            if let product = SubscriptionProduct(rawValue: autoRenewProductId) {
                                Text(product.displayName)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        } header: {
            Text("구독 상세")
        }
    }
    
    /// 갱신 상태 텍스트
    private func renewalStateText(_ state: Product.SubscriptionInfo.RenewalState) -> String {
        switch state {
        case .subscribed:
            return "구독 중"
        case .expired:
            return "만료됨"
        case .inBillingRetryPeriod:
            return "결제 재시도 중"
        case .inGracePeriod:
            return "유예 기간"
        case .revoked:
            return "취소됨"
        default:
            return "알 수 없음"
        }
    }
    
    /// 갱신 상태 색상
    private func renewalStateColor(_ state: Product.SubscriptionInfo.RenewalState) -> Color {
        switch state {
        case .subscribed:
            return .green
        case .expired, .revoked:
            return .red
        case .inBillingRetryPeriod, .inGracePeriod:
            return .orange
        default:
            return .secondary
        }
    }
    
    // MARK: - 문제 해결 섹션
    
    private var troubleshootingSection: some View {
        Section {
            // 구매 복원
            Button {
                Task {
                    isLoading = true
                    await subscriptionManager.restorePurchases()
                    isLoading = false
                }
            } label: {
                HStack {
                    Label("구매 복원", systemImage: "arrow.clockwise")
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                    }
                }
            }
            .disabled(isLoading)
            
            // 상태 새로고침
            Button {
                Task {
                    await refreshStatus()
                }
            } label: {
                Label("상태 새로고침", systemImage: "arrow.triangle.2.circlepath")
            }
            
            // App Store 구독 관리로 이동
            if let manageURL = URL(string: "https://apps.apple.com/account/subscriptions") {
                Link(destination: manageURL) {
                    Label("App Store에서 관리", systemImage: "arrow.up.right.square")
                }
            }
        } header: {
            Text("문제 해결")
        } footer: {
            Text("구독이 표시되지 않으면 '구매 복원'을 시도하세요. 문제가 계속되면 Apple 지원에 문의하세요.")
        }
    }
    
    // MARK: - 데이터 로드
    
    /// 구독 상태 로드
    private func loadSubscriptionStatus() async {
        guard let product = subscriptionManager.activeSubscription else { return }
        subscriptionStatus = await subscriptionManager.subscriptionStatus(for: product)
    }
    
    /// 상태 새로고침
    private func refreshStatus() async {
        isLoading = true
        await subscriptionManager.updateSubscriptionStatus()
        await loadSubscriptionStatus()
        isLoading = false
    }
}

// MARK: - 프리뷰

#Preview {
    NavigationStack {
        SubscriptionStatusView()
            .environmentObject(SubscriptionManager.shared)
            .environmentObject(EntitlementManager.shared)
    }
}
