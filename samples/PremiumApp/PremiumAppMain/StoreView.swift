import SwiftUI

// MARK: - StoreView
/// 상품 목록을 표시하고 구매를 처리하는 뷰
/// 비소모성, 소모성 상품을 카테고리별로 정리합니다.

struct StoreView: View {
    // MARK: - 환경 및 상태
    
    @Environment(StoreManager.self) private var storeManager
    
    /// 현재 구매 중인 상품 ID
    @State private var purchasingProductID: String?
    
    /// 알림 표시 여부
    @State private var showAlert = false
    
    /// 알림 메시지
    @State private var alertMessage = ""
    
    // MARK: - 뷰 본문
    
    var body: some View {
        NavigationStack {
            Group {
                if storeManager.isLoading {
                    // 로딩 중
                    loadingView
                } else if storeManager.products.isEmpty {
                    // 상품 없음
                    emptyView
                } else {
                    // 상품 목록
                    productList
                }
            }
            .navigationTitle("스토어")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("복원") {
                        Task {
                            await storeManager.restorePurchases()
                            alertMessage = "구매가 복원되었습니다."
                            showAlert = true
                        }
                    }
                }
            }
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - 로딩 뷰
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("상품을 불러오는 중...")
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("상품 없음", systemImage: "bag")
        } description: {
            Text("현재 이용 가능한 상품이 없습니다.")
        } actions: {
            Button("다시 시도") {
                Task {
                    await storeManager.loadProducts()
                }
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - 상품 목록
    
    private var productList: some View {
        List {
            // MARK: 비소모성 상품 섹션
            if !storeManager.nonConsumables.isEmpty {
                Section {
                    ForEach(storeManager.nonConsumables) { product in
                        ProductRow(
                            product: product,
                            isPurchased: storeManager.isPurchased(product.id),
                            isPurchasing: purchasingProductID == product.id,
                            onPurchase: { await purchaseProduct(product) }
                        )
                    }
                } header: {
                    Text("프리미엄 기능")
                } footer: {
                    Text("한 번 구매로 영구 소유")
                }
            }
            
            // MARK: 소모성 상품 섹션
            if !storeManager.consumables.isEmpty {
                Section {
                    ForEach(storeManager.consumables) { product in
                        ProductRow(
                            product: product,
                            isPurchased: false, // 소모성은 항상 구매 가능
                            isPurchasing: purchasingProductID == product.id,
                            onPurchase: { await purchaseProduct(product) }
                        )
                    }
                } header: {
                    Text("코인")
                } footer: {
                    Text("여러 번 구매 가능")
                }
            }
            
            // MARK: 구독 섹션 (간략)
            Section {
                NavigationLink {
                    SubscriptionView()
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                        
                        VStack(alignment: .leading) {
                            Text("구독 플랜")
                                .font(.headline)
                            
                            Text(storeManager.subscriptionStatus.isEntitled
                                 ? "현재 구독 중"
                                 : "구독하고 모든 기능 이용하기")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - 구매 처리
    
    private func purchaseProduct(_ product: ProductItem) async {
        purchasingProductID = product.id
        
        let success = await storeManager.purchase(product)
        
        purchasingProductID = nil
        
        if success {
            alertMessage = "\(product.displayName) 구매가 완료되었습니다!"
            showAlert = true
        } else if case .failed(let error) = storeManager.purchaseState {
            alertMessage = error.localizedDescription
            showAlert = true
        }
        
        // 상태 초기화
        storeManager.resetPurchaseState()
    }
}

// MARK: - ProductRow
/// 개별 상품을 표시하는 행

struct ProductRow: View {
    let product: ProductItem
    let isPurchased: Bool
    let isPurchasing: Bool
    let onPurchase: () async -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 상품 아이콘
            productIcon
            
            // 상품 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                Text(product.typeDescription)
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
            
            Spacer()
            
            // 구매 버튼
            purchaseButton
        }
        .padding(.vertical, 4)
    }
    
    // MARK: 상품 아이콘
    
    private var productIcon: some View {
        Image(systemName: iconName)
            .font(.title)
            .foregroundStyle(iconColor)
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(iconColor.opacity(0.15))
            )
    }
    
    private var iconName: String {
        switch product.type {
        case .consumable:
            return "c.circle.fill"
        case .nonConsumable:
            return "star.fill"
        case .autoRenewable:
            return "crown.fill"
        default:
            return "bag.fill"
        }
    }
    
    private var iconColor: Color {
        switch product.type {
        case .consumable:
            return .orange
        case .nonConsumable:
            return .purple
        case .autoRenewable:
            return .yellow
        default:
            return .blue
        }
    }
    
    // MARK: 구매 버튼
    
    @ViewBuilder
    private var purchaseButton: some View {
        if isPurchased {
            // 구매 완료
            Label("구매됨", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)
        } else if isPurchasing {
            // 구매 중
            ProgressView()
                .frame(width: 60)
        } else {
            // 구매 버튼
            Button {
                Task {
                    await onPurchase()
                }
            } label: {
                Text(product.displayPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    StoreView()
        .environment(StoreManager.shared)
}
