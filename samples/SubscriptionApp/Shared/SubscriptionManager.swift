import StoreKit
import SwiftUI

// MARK: - 구독 관리자
// StoreKit 2를 사용한 구독 관리 클래스

/// 구독 구매 및 상태 관리를 담당하는 ObservableObject
@MainActor
final class SubscriptionManager: ObservableObject {
    
    // MARK: - 싱글톤
    
    /// 공유 인스턴스
    static let shared = SubscriptionManager()
    
    // MARK: - Published 프로퍼티
    
    /// 사용 가능한 구독 상품 목록
    @Published private(set) var products: [Product] = []
    
    /// 현재 활성화된 구독
    @Published private(set) var activeSubscription: Product?
    
    /// 구매 진행 중 상태
    @Published private(set) var isPurchasing = false
    
    /// 상품 로딩 중 상태
    @Published private(set) var isLoading = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - 트랜잭션 리스너
    
    /// 트랜잭션 업데이트 리스너 태스크
    private var transactionListener: Task<Void, Error>?
    
    // MARK: - 초기화
    
    private init() {
        // 트랜잭션 리스너 시작
        transactionListener = listenForTransactions()
        
        // 초기 상품 로드 및 구독 상태 확인
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        // 리스너 정리
        transactionListener?.cancel()
    }
    
    // MARK: - 트랜잭션 리스너
    
    /// 트랜잭션 업데이트를 실시간으로 감지합니다.
    /// 앱 외부에서 발생한 구매(예: 가족 공유, 프로모션 코드)도 처리합니다.
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            // Transaction.updates는 새로운 트랜잭션이 발생할 때마다 알림
            for await result in Transaction.updates {
                do {
                    let transaction = try self?.checkVerified(result)
                    
                    // 트랜잭션 완료 처리
                    await transaction?.finish()
                    
                    // UI 업데이트
                    await self?.updateSubscriptionStatus()
                } catch {
                    print("트랜잭션 검증 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 상품 로드
    
    /// App Store에서 구독 상품 정보를 로드합니다.
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // StoreKit 2 API로 상품 정보 요청
            let storeProducts = try await Product.products(
                for: SubscriptionProduct.allProductIDs
            )
            
            // 가격 순으로 정렬 (낮은 가격부터)
            products = storeProducts.sorted { $0.price < $1.price }
            
            print("✅ \(products.count)개의 구독 상품을 로드했습니다.")
        } catch {
            errorMessage = "상품을 불러오는데 실패했습니다: \(error.localizedDescription)"
            print("❌ 상품 로드 실패: \(error)")
        }
    }
    
    // MARK: - 구독 구매
    
    /// 구독 상품을 구매합니다.
    /// - Parameter product: 구매할 Product
    /// - Returns: 구매 성공 여부
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            // 구매 요청
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // 트랜잭션 검증
                let transaction = try checkVerified(verification)
                
                // 트랜잭션 완료 처리 (필수!)
                await transaction.finish()
                
                // 구독 상태 업데이트
                await updateSubscriptionStatus()
                
                print("✅ 구독 구매 완료: \(product.displayName)")
                return true
                
            case .userCancelled:
                // 사용자가 구매를 취소함
                print("ℹ️ 사용자가 구매를 취소했습니다.")
                return false
                
            case .pending:
                // 구매 승인 대기 중 (예: 부모 승인 필요)
                print("⏳ 구매 승인 대기 중...")
                return false
                
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "구매 중 오류가 발생했습니다: \(error.localizedDescription)"
            print("❌ 구매 실패: \(error)")
            return false
        }
    }
    
    // MARK: - 구독 상태 업데이트
    
    /// 현재 활성화된 구독 상태를 확인하고 업데이트합니다.
    func updateSubscriptionStatus() async {
        // 현재 사용자의 모든 자격(entitlements) 확인
        var highestProduct: Product?
        var highestTier: SubscriptionTier = .none
        
        // currentEntitlements: 현재 유효한 모든 구매/구독 확인
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // 구독 상품인 경우만 처리
                if transaction.productType == .autoRenewable {
                    // 해당 상품 찾기
                    if let product = products.first(where: { $0.id == transaction.productID }),
                       let subscriptionProduct = SubscriptionProduct(rawValue: product.id) {
                        
                        let tier = subscriptionProduct.tier
                        
                        // 더 높은 티어의 구독이면 업데이트
                        if tier > highestTier {
                            highestTier = tier
                            highestProduct = product
                        }
                    }
                }
            } catch {
                print("자격 검증 실패: \(error)")
            }
        }
        
        activeSubscription = highestProduct
        
        // EntitlementManager도 함께 업데이트
        if let subscriptionProduct = activeSubscription.flatMap({ SubscriptionProduct(rawValue: $0.id) }) {
            EntitlementManager.shared.updateEntitlement(for: subscriptionProduct.tier)
        } else {
            EntitlementManager.shared.updateEntitlement(for: .none)
        }
    }
    
    // MARK: - 구매 복원
    
    /// 이전 구매를 복원합니다.
    /// App Store에 저장된 구매 기록을 동기화합니다.
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // App Store 서버와 동기화
            try await AppStore.sync()
            
            // 구독 상태 업데이트
            await updateSubscriptionStatus()
            
            print("✅ 구매 복원 완료")
        } catch {
            errorMessage = "구매 복원에 실패했습니다: \(error.localizedDescription)"
            print("❌ 구매 복원 실패: \(error)")
        }
    }
    
    // MARK: - 트랜잭션 검증
    
    /// 트랜잭션의 서명을 검증합니다.
    /// StoreKit 2는 자동으로 서명을 검증하지만, 결과를 확인해야 합니다.
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            // 검증 실패 - 위변조된 트랜잭션일 수 있음
            throw error
        case .verified(let item):
            // 검증 성공 - 안전하게 사용 가능
            return item
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 특정 상품 ID로 Product 찾기
    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }
    
    /// 현재 구독 중인지 확인
    var isSubscribed: Bool {
        activeSubscription != nil
    }
    
    /// 현재 구독의 자동 갱신 정보
    func subscriptionStatus(for product: Product) async -> Product.SubscriptionInfo.Status? {
        guard let subscription = product.subscription else { return nil }
        
        do {
            let statuses = try await subscription.status
            return statuses.first
        } catch {
            print("구독 상태 조회 실패: \(error)")
            return nil
        }
    }
}

// MARK: - Product 확장

extension Product {
    /// 가격을 현지화된 문자열로 반환
    var localizedPrice: String {
        displayPrice
    }
    
    /// 구독 기간 설명
    var periodDescription: String? {
        guard let subscription = subscription else { return nil }
        
        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value
        
        switch unit {
        case .day:
            return value == 1 ? "일" : "\(value)일"
        case .week:
            return value == 1 ? "주" : "\(value)주"
        case .month:
            return value == 1 ? "월" : "\(value)개월"
        case .year:
            return value == 1 ? "연" : "\(value)년"
        @unknown default:
            return nil
        }
    }
}
