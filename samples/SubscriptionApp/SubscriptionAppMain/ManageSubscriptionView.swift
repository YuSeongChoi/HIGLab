import SwiftUI
import StoreKit

// MARK: - 구독 관리 뷰
// 구독 업그레이드, 다운그레이드, 취소 등을 관리합니다.

struct ManageSubscriptionView: View {
    
    // MARK: - 환경
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    // MARK: - 상태
    
    /// 선택된 새 상품 (변경할 상품)
    @State private var selectedProduct: Product?
    
    /// 변경 확인 얼럿
    @State private var showChangeConfirmation = false
    
    /// 취소 확인 얼럿
    @State private var showCancelConfirmation = false
    
    /// 변경 처리 중
    @State private var isProcessing = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // 현재 구독 정보
                currentSubscriptionSection
                
                // 플랜 변경 섹션
                changePlanSection
                
                // 구독 취소 섹션
                cancelSection
            }
            .navigationTitle("구독 관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .alert("구독 변경", isPresented: $showChangeConfirmation) {
                Button("변경", role: .destructive) {
                    Task {
                        await changePlan()
                    }
                }
                Button("취소", role: .cancel) {
                    selectedProduct = nil
                }
            } message: {
                if let product = selectedProduct {
                    Text("'\(product.displayName)'으로 변경하시겠습니까?\n\n변경사항은 다음 결제일부터 적용됩니다.")
                }
            }
            .alert("구독 취소", isPresented: $showCancelConfirmation) {
                Button("App Store에서 취소", role: .destructive) {
                    openSubscriptionManagement()
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("구독을 취소하려면 App Store 설정에서 진행해야 합니다.\n\n취소 후에도 현재 결제 기간이 끝날 때까지 서비스를 이용할 수 있습니다.")
            }
        }
    }
    
    // MARK: - 현재 구독 섹션
    
    private var currentSubscriptionSection: some View {
        Section {
            if let product = subscriptionManager.activeSubscription,
               let subscriptionProduct = SubscriptionProduct(rawValue: product.id) {
                
                VStack(alignment: .leading, spacing: 12) {
                    // 플랜 이름
                    HStack {
                        VStack(alignment: .leading) {
                            Text(subscriptionProduct.displayName)
                                .font(.headline)
                            
                            Text(subscriptionProduct.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 티어 배지
                        Text(subscriptionProduct.tier.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(tierBadgeColor.opacity(0.1))
                            .foregroundColor(tierBadgeColor)
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // 가격 정보
                    HStack {
                        Text("현재 가격")
                        Spacer()
                        Text("\(product.displayPrice) / \(product.periodDescription ?? "")")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("현재 플랜")
        } footer: {
            Text("구독은 선택한 기간에 따라 자동으로 갱신됩니다.")
        }
    }
    
    /// 티어 배지 색상
    private var tierBadgeColor: Color {
        switch entitlementManager.currentTier {
        case .none:
            return .gray
        case .basic:
            return .blue
        case .premium:
            return .purple
        }
    }
    
    // MARK: - 플랜 변경 섹션
    
    private var changePlanSection: some View {
        Section {
            ForEach(availablePlans, id: \.id) { product in
                PlanOptionRow(
                    product: product,
                    isCurrentPlan: isCurrentPlan(product),
                    isSelected: selectedProduct?.id == product.id
                ) {
                    if !isCurrentPlan(product) {
                        selectedProduct = product
                        showChangeConfirmation = true
                    }
                }
            }
        } header: {
            Text("플랜 변경")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("• 업그레이드: 즉시 적용되며, 남은 기간에 대해 비례 계산됩니다.")
                Text("• 다운그레이드: 현재 기간이 끝난 후 적용됩니다.")
            }
            .font(.caption2)
        }
    }
    
    /// 변경 가능한 플랜 목록 (현재 플랜 제외)
    private var availablePlans: [Product] {
        subscriptionManager.products.sorted { product1, product2 in
            // 티어 우선, 그 다음 가격 순
            guard let sub1 = SubscriptionProduct(rawValue: product1.id),
                  let sub2 = SubscriptionProduct(rawValue: product2.id) else {
                return product1.price < product2.price
            }
            
            if sub1.tier != sub2.tier {
                return sub1.tier < sub2.tier
            }
            return product1.price < product2.price
        }
    }
    
    /// 현재 구독 중인 플랜인지 확인
    private func isCurrentPlan(_ product: Product) -> Bool {
        subscriptionManager.activeSubscription?.id == product.id
    }
    
    /// 플랜 변경 실행
    private func changePlan() async {
        guard let product = selectedProduct else { return }
        
        isProcessing = true
        defer {
            isProcessing = false
            selectedProduct = nil
        }
        
        // 새 상품 구매 (StoreKit이 자동으로 업/다운그레이드 처리)
        let success = await subscriptionManager.purchase(product)
        
        if success {
            dismiss()
        }
    }
    
    // MARK: - 취소 섹션
    
    private var cancelSection: some View {
        Section {
            Button(role: .destructive) {
                showCancelConfirmation = true
            } label: {
                HStack {
                    Text("구독 취소")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } footer: {
            Text("구독을 취소해도 현재 결제 기간이 끝날 때까지 모든 기능을 이용할 수 있습니다.")
        }
    }
    
    /// App Store 구독 관리 페이지 열기
    private func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - 플랜 옵션 행

struct PlanOptionRow: View {
    let product: Product
    let isCurrentPlan: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    
    /// SubscriptionProduct 정보
    private var subscriptionProduct: SubscriptionProduct? {
        SubscriptionProduct(rawValue: product.id)
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // 플랜 정보
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(subscriptionProduct?.displayName ?? product.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if isCurrentPlan {
                            Text("현재")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                        
                        if subscriptionProduct?.tier == .premium && !isCurrentPlan {
                            Text("추천")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(subscriptionProduct?.description ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 가격
                VStack(alignment: .trailing) {
                    Text(product.displayPrice)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("/\(product.periodDescription ?? "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 선택 표시
                if !isCurrentPlan {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .disabled(isCurrentPlan)
        .listRowBackground(
            isCurrentPlan
                ? Color.green.opacity(0.05)
                : Color.clear
        )
    }
}

// MARK: - 프리뷰

#Preview {
    ManageSubscriptionView()
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(EntitlementManager.shared)
}
