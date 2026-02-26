import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @State private var storeManager = StoreManager()
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    headerSection
                    
                    // 현재 구독 상태
                    statusSection
                    
                    // 프리미엄 혜택
                    benefitsSection
                    
                    // 구독 옵션
                    subscriptionOptions
                    
                    // 복원 버튼
                    restoreButton
                    
                    // 법적 문구
                    legalText
                }
                .padding()
            }
            .navigationTitle("프리미엄")
            .alert("오류", isPresented: $showError) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow.gradient)
            
            Text("HIG Lab Premium")
                .font(.title)
                .fontWeight(.bold)
            
            Text("더 나은 쇼핑 경험을 위한\n프리미엄 멤버십")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        Group {
            switch storeManager.subscriptionStatus {
            case .subscribed(let expirationDate):
                VStack(spacing: 8) {
                    Label("프리미엄 구독 중", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                    
                    if let date = expirationDate {
                        Text("만료일: \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
            case .expired:
                Label("구독 만료됨", systemImage: "exclamationmark.circle")
                    .font(.headline)
                    .foregroundStyle(.orange)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
            case .notSubscribed:
                EmptyView()
            }
        }
    }
    
    // MARK: - Benefits Section
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("프리미엄 혜택")
                .font(.headline)
            
            BenefitRow(icon: "truck.box.fill", title: "무료 배송", description: "모든 주문 무료 배송")
            BenefitRow(icon: "percent", title: "추가 할인", description: "모든 상품 10% 추가 할인")
            BenefitRow(icon: "clock.arrow.circlepath", title: "우선 배송", description: "일반 고객보다 빠른 배송")
            BenefitRow(icon: "arrow.uturn.left.circle.fill", title: "무료 반품", description: "30일 무료 반품 서비스")
            BenefitRow(icon: "headphones", title: "전담 상담", description: "프리미엄 고객 전용 상담")
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Subscription Options
    private var subscriptionOptions: some View {
        VStack(spacing: 12) {
            Text("구독 플랜 선택")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 월간 구독
            SubscriptionCard(
                title: "월간 구독",
                price: "₩9,900/월",
                description: "언제든 해지 가능",
                isBestValue: false,
                isPurchasing: isPurchasing
            ) {
                purchase("com.higlab.ecommerce.premium.monthly")
            }
            
            // 연간 구독
            SubscriptionCard(
                title: "연간 구독",
                price: "₩79,900/년",
                description: "월 ₩6,658 (33% 할인)",
                isBestValue: true,
                isPurchasing: isPurchasing
            ) {
                purchase("com.higlab.ecommerce.premium.yearly")
            }
        }
    }
    
    // MARK: - Restore Button
    private var restoreButton: some View {
        Button {
            Task {
                do {
                    try await storeManager.restore()
                } catch {
                    errorMessage = "복원에 실패했습니다."
                    showError = true
                }
            }
        } label: {
            Text("구매 복원")
                .font(.subheadline)
                .foregroundStyle(.accent)
        }
    }
    
    // MARK: - Legal Text
    private var legalText: some View {
        Text("구독은 현재 기간 종료 최소 24시간 전에 자동 갱신 해제하지 않으면 자동으로 갱신됩니다. Apple ID 계정의 설정에서 구독을 관리하고 자동 갱신을 해제할 수 있습니다.")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Purchase
    private func purchase(_ productId: String) {
        isPurchasing = true
        
        Task {
            do {
                _ = try await storeManager.purchase(productId)
            } catch {
                errorMessage = "구매에 실패했습니다."
                showError = true
            }
            isPurchasing = false
        }
    }
}

// MARK: - Benefit Row
struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.accent)
                .frame(width: 36)
            
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

// MARK: - Subscription Card
struct SubscriptionCard: View {
    let title: String
    let price: String
    let description: String
    let isBestValue: Bool
    let isPurchasing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        
                        if isBestValue {
                            Text("BEST")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isPurchasing {
                    ProgressView()
                } else {
                    Text(price)
                        .font(.headline)
                        .foregroundStyle(.accent)
                }
            }
            .padding()
            .background(isBestValue ? Color.accent.opacity(0.1) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isBestValue ? Color.accent : Color.gray.opacity(0.3), lineWidth: isBestValue ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }
}

#Preview {
    SubscriptionView()
}
