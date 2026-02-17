import SwiftUI

// MARK: - SubscriptionView
/// 구독 상품 및 현재 구독 상태를 관리하는 뷰
/// 월간/연간 구독 플랜을 표시하고 구독 관리 기능을 제공합니다.

struct SubscriptionView: View {
    // MARK: - 환경 및 상태
    
    @Environment(StoreManager.self) private var storeManager
    @Environment(\.dismiss) private var dismiss
    
    /// 선택된 구독 플랜
    @State private var selectedPlan: ProductItem?
    
    /// 구매 진행 중 여부
    @State private var isPurchasing = false
    
    /// 알림 표시
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - 뷰 본문
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 현재 구독 상태
                    if storeManager.subscriptionStatus.isEntitled {
                        currentSubscriptionCard
                    }
                    
                    // 구독 혜택
                    benefitsSection
                    
                    // 구독 플랜 선택
                    plansSection
                    
                    // 구독 버튼
                    if !storeManager.subscriptionStatus.isEntitled {
                        subscribeButton
                    }
                    
                    // 약관 및 안내
                    legalSection
                }
                .padding()
            }
            .navigationTitle("프리미엄 구독")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if storeManager.subscriptionStatus.isEntitled {
                        Button("구독 관리") {
                            openSubscriptionManagement()
                        }
                    }
                }
            }
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                // 기본 플랜 선택 (연간 추천)
                if selectedPlan == nil {
                    selectedPlan = storeManager.subscriptions.first {
                        $0.id == ProductItem.ProductID.yearlySubscription
                    } ?? storeManager.subscriptions.first
                }
            }
        }
    }
    
    // MARK: - 현재 구독 카드
    
    private var currentSubscriptionCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundStyle(.yellow)
            
            Text("프리미엄 구독 중")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(storeManager.subscriptionStatus.description)
                .foregroundStyle(.secondary)
            
            if let expirationDate = storeManager.subscriptionExpirationDate {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text("다음 갱신: \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    // MARK: - 혜택 섹션
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("프리미엄 혜택")
                .font(.headline)
            
            BenefitRow(icon: "xmark.circle", title: "광고 제거", description: "모든 광고 없이 깔끔하게")
            BenefitRow(icon: "paintbrush.fill", title: "고급 테마", description: "프리미엄 전용 테마 사용")
            BenefitRow(icon: "icloud.fill", title: "클라우드 동기화", description: "모든 기기에서 데이터 동기화")
            BenefitRow(icon: "infinity", title: "무제한 저장", description: "저장 공간 제한 없음")
            BenefitRow(icon: "star.fill", title: "우선 지원", description: "빠른 고객 지원")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - 플랜 섹션
    
    private var plansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("구독 플랜 선택")
                .font(.headline)
            
            ForEach(storeManager.subscriptions) { plan in
                PlanCard(
                    product: plan,
                    isSelected: selectedPlan?.id == plan.id,
                    isCurrentPlan: storeManager.isPurchased(plan.id),
                    onSelect: { selectedPlan = plan }
                )
            }
        }
    }
    
    // MARK: - 구독 버튼
    
    private var subscribeButton: some View {
        Button {
            Task {
                await subscribe()
            }
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("구독 시작하기")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .disabled(selectedPlan == nil || isPurchasing)
    }
    
    // MARK: - 약관 섹션
    
    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("구독은 선택한 기간이 종료되면 자동으로 갱신됩니다. 설정에서 언제든지 취소할 수 있습니다.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("이용약관") {
                    // 이용약관 URL 열기
                }
                .font(.caption)
                
                Button("개인정보 처리방침") {
                    // 개인정보 처리방침 URL 열기
                }
                .font(.caption)
            }
        }
        .padding(.top)
    }
    
    // MARK: - 액션
    
    /// 구독 시작
    private func subscribe() async {
        guard let plan = selectedPlan else { return }
        
        isPurchasing = true
        
        let success = await storeManager.purchase(plan)
        
        isPurchasing = false
        
        if success {
            alertMessage = "프리미엄 구독이 시작되었습니다!"
            showAlert = true
        } else if case .failed(let error) = storeManager.purchaseState {
            alertMessage = error.localizedDescription
            showAlert = true
        }
        
        storeManager.resetPurchaseState()
    }
    
    /// 구독 관리 페이지 열기
    private func openSubscriptionManagement() {
        // App Store 구독 관리 페이지로 이동
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - BenefitRow
/// 혜택 항목 행

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - PlanCard
/// 구독 플랜 카드

struct PlanCard: View {
    let product: ProductItem
    let isSelected: Bool
    let isCurrentPlan: Bool
    let onSelect: () -> Void
    
    /// 연간 플랜인지 확인
    private var isYearly: Bool {
        product.id == ProductItem.ProductID.yearlySubscription
    }
    
    /// 할인 표시 (연간 플랜용)
    private var savingsText: String? {
        if isYearly {
            return "인기" // 실제로는 월간 대비 할인율 계산
        }
        return nil
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.displayName)
                            .font(.headline)
                        
                        if let savings = savingsText {
                            Text(savings)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(product.displayPrice)
                        .font(.headline)
                    
                    if isYearly {
                        Text("월 \(monthlyEquivalent)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 선택 표시
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .blue : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .blue : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isCurrentPlan)
        .opacity(isCurrentPlan ? 0.7 : 1)
        .overlay(alignment: .topTrailing) {
            if isCurrentPlan {
                Text("현재 플랜")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green)
                    .clipShape(Capsule())
                    .offset(x: -8, y: -8)
            }
        }
    }
    
    /// 월 환산 가격 (연간 플랜용)
    private var monthlyEquivalent: String {
        let monthly = product.price / 12
        // 간단한 포맷 (실제로는 NumberFormatter 사용)
        return String(format: "₩%.0f", NSDecimalNumber(decimal: monthly).doubleValue)
    }
}

// MARK: - 프리뷰

#Preview {
    SubscriptionView()
        .environment(StoreManager.shared)
}
