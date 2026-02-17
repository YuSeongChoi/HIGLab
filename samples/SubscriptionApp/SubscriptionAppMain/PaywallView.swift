import SwiftUI
import StoreKit

// MARK: - 페이월 뷰
// 구독 상품을 선택하고 구매할 수 있는 화면

struct PaywallView: View {
    
    // MARK: - 환경
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    // MARK: - 상태
    
    /// 선택된 상품
    @State private var selectedProduct: Product?
    
    /// 선택된 구독 기간 (월간/연간)
    @State private var selectedPeriod: SubscriptionPeriod = .yearly
    
    /// 구매 확인 얼럿
    @State private var showPurchaseConfirmation = false
    
    /// 에러 얼럿
    @State private var showError = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 헤더 이미지 및 제목
                    headerSection
                    
                    // 혜택 목록
                    benefitsSection
                    
                    // 기간 선택 (월간/연간)
                    periodPicker
                    
                    // 상품 선택
                    productSelection
                    
                    // 구매 버튼
                    purchaseButton
                    
                    // 하단 정보
                    footerSection
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert("구매 오류", isPresented: $showError) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(subscriptionManager.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
            .onChange(of: subscriptionManager.errorMessage) { _, newValue in
                showError = newValue != nil
            }
        }
        .onAppear {
            selectDefaultProduct()
        }
    }
    
    // MARK: - 헤더 섹션
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 왕관 아이콘
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("프리미엄으로 업그레이드")
                .font(.title)
                .fontWeight(.bold)
            
            Text("모든 기능을 제한 없이 이용하세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    // MARK: - 혜택 섹션
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            BenefitRow(icon: "eye.slash.fill", text: "모든 광고 제거", color: .blue)
            BenefitRow(icon: "icloud.fill", text: "클라우드 동기화", color: .cyan)
            BenefitRow(icon: "star.fill", text: "독점 콘텐츠 접근", color: .yellow)
            BenefitRow(icon: "paintpalette.fill", text: "맞춤 테마", color: .purple)
            BenefitRow(icon: "person.crop.circle.badge.checkmark", text: "우선 지원", color: .green)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - 기간 선택
    
    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach([SubscriptionPeriod.monthly, .yearly], id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPeriod = period
                        selectDefaultProduct()
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(period.rawValue)
                            .font(.headline)
                        
                        if period == .yearly {
                            Text("\(period.savingsPercentage)% 할인")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedPeriod == period
                            ? Color.blue
                            : Color.clear
                    )
                    .foregroundColor(
                        selectedPeriod == period
                            ? .white
                            : .primary
                    )
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - 상품 선택
    
    private var productSelection: some View {
        VStack(spacing: 12) {
            ForEach(filteredProducts, id: \.id) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id
                ) {
                    withAnimation(.spring(response: 0.2)) {
                        selectedProduct = product
                    }
                }
            }
        }
    }
    
    /// 선택된 기간에 맞는 상품만 필터링
    private var filteredProducts: [Product] {
        subscriptionManager.products.filter { product in
            guard let subscriptionProduct = SubscriptionProduct(rawValue: product.id) else {
                return false
            }
            return subscriptionProduct.period == selectedPeriod
        }
    }
    
    /// 기본 상품 선택 (프리미엄 우선)
    private func selectDefaultProduct() {
        selectedProduct = filteredProducts.last // 마지막이 프리미엄 (높은 가격)
    }
    
    // MARK: - 구매 버튼
    
    private var purchaseButton: some View {
        Button {
            Task {
                if let product = selectedProduct {
                    let success = await subscriptionManager.purchase(product)
                    if success {
                        dismiss()
                    }
                }
            }
        } label: {
            HStack {
                if subscriptionManager.isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("지금 구독하기")
                        .fontWeight(.bold)
                    
                    if let product = selectedProduct {
                        Text("• \(product.displayPrice)/\(product.periodDescription ?? "")")
                    }
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(selectedProduct == nil || subscriptionManager.isPurchasing)
    }
    
    // MARK: - 하단 섹션
    
    private var footerSection: some View {
        VStack(spacing: 8) {
            // 복원 버튼
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            } label: {
                Text("이전 구매 복원")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            // 약관 안내
            VStack(spacing: 4) {
                Text("구독은 선택한 기간에 따라 자동으로 갱신됩니다.")
                Text("언제든지 설정에서 구독을 취소할 수 있습니다.")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            
            // 링크
            HStack(spacing: 16) {
                Link("이용약관", destination: URL(string: "https://example.com/terms")!)
                Link("개인정보처리방침", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.caption)
        }
    }
}

// MARK: - 혜택 행

struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.caption)
        }
    }
}

// MARK: - 상품 카드

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    /// 해당 SubscriptionProduct 정보
    private var subscriptionProduct: SubscriptionProduct? {
        SubscriptionProduct(rawValue: product.id)
    }
    
    /// 프리미엄 상품 여부
    private var isPremium: Bool {
        subscriptionProduct?.tier == .premium
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(subscriptionProduct?.displayName ?? product.displayName)
                            .font(.headline)
                        
                        if isPremium {
                            Text("인기")
                                .font(.caption2)
                                .fontWeight(.bold)
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
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("/\(product.periodDescription ?? "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 프리뷰

#Preview {
    PaywallView()
        .environmentObject(SubscriptionManager.shared)
}
