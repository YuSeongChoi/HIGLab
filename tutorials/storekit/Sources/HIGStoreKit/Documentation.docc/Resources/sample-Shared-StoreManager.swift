import StoreKit
import Observation

// MARK: - StoreManager
/// StoreKit 2를 사용한 인앱 구매 관리자
/// 상품 조회, 구매, 복원, 구독 상태 관리를 담당합니다.

@MainActor
@Observable
final class StoreManager {
    // MARK: - 싱글톤
    
    /// 공유 인스턴스
    static let shared = StoreManager()
    
    // MARK: - 상품 목록
    
    /// 모든 상품
    private(set) var products: [ProductItem] = []
    
    /// 비소모성 상품
    var nonConsumables: [ProductItem] {
        products.filter { $0.isNonConsumable }
    }
    
    /// 소모성 상품
    var consumables: [ProductItem] {
        products.filter { $0.isConsumable }
    }
    
    /// 구독 상품
    var subscriptions: [ProductItem] {
        products.filter { $0.isSubscription }
    }
    
    // MARK: - 구매 상태
    
    /// 현재 구매 상태
    private(set) var purchaseState: PurchaseState = .idle
    
    /// 구매한 상품 ID 목록
    private(set) var purchasedProductIDs: Set<String> = []
    
    /// 현재 구독 상태
    private(set) var subscriptionStatus: SubscriptionStatus = .none
    
    /// 구독 만료 날짜
    private(set) var subscriptionExpirationDate: Date?
    
    /// 상품 로딩 중 여부
    private(set) var isLoading = false
    
    // MARK: - 트랜잭션 리스너
    
    /// 트랜잭션 업데이트 감시 태스크
    private var transactionListener: Task<Void, Never>?
    
    // MARK: - 초기화
    
    private init() {
        // 트랜잭션 리스너 시작
        startTransactionListener()
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - 상품 로드
    
    /// App Store에서 상품 정보를 가져옵니다.
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // StoreKit에서 상품 정보 요청
            let storeProducts = try await Product.products(for: ProductItem.ProductID.all)
            
            // ProductItem으로 변환
            products = storeProducts.map { ProductItem(product: $0) }
            
            // 가격순 정렬
            products.sort { $0.price < $1.price }
            
            // 현재 구매 상태 업데이트
            await updatePurchasedProducts()
            
            print("✅ 상품 로드 완료: \(products.count)개")
            
        } catch {
            print("❌ 상품 로드 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 구매
    
    /// 상품을 구매합니다.
    /// - Parameter product: 구매할 상품
    /// - Returns: 구매 성공 여부
    @discardableResult
    func purchase(_ product: ProductItem) async -> Bool {
        purchaseState = .purchasing
        
        do {
            // 구매 요청
            let result = try await product.product.purchase()
            
            switch result {
            case .success(let verification):
                // 영수증 검증
                let transaction = try checkVerification(verification)
                
                // 구매 완료 처리
                await handlePurchase(transaction)
                
                // 트랜잭션 완료 처리 (필수!)
                await transaction.finish()
                
                purchaseState = .purchased
                print("✅ 구매 성공: \(product.displayName)")
                return true
                
            case .userCancelled:
                // 사용자가 취소
                purchaseState = .cancelled
                print("ℹ️ 사용자가 구매를 취소했습니다.")
                return false
                
            case .pending:
                // 승인 대기 (가족 공유 등)
                purchaseState = .pending
                print("⏳ 구매 승인 대기 중...")
                return false
                
            @unknown default:
                purchaseState = .failed(PurchaseError.unknown)
                return false
            }
            
        } catch {
            purchaseState = .failed(error)
            print("❌ 구매 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 구매 상태를 초기화합니다.
    func resetPurchaseState() {
        purchaseState = .idle
    }
    
    // MARK: - 구매 복원
    
    /// 이전 구매를 복원합니다.
    /// 비소모성 상품과 활성 구독을 복원합니다.
    func restorePurchases() async {
        do {
            // App Store와 동기화
            try await AppStore.sync()
            
            // 구매 상태 업데이트
            await updatePurchasedProducts()
            
            print("✅ 구매 복원 완료")
            
        } catch {
            print("❌ 구매 복원 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 권한 확인
    
    /// 프리미엄 기능 사용 권한이 있는지 확인합니다.
    var isPremium: Bool {
        // 프리미엄 언락 구매 확인
        if purchasedProductIDs.contains(ProductItem.ProductID.premiumUnlock) {
            return true
        }
        
        // 활성 구독 확인
        if subscriptionStatus.isEntitled {
            return true
        }
        
        return false
    }
    
    /// 특정 상품을 구매했는지 확인합니다.
    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
    
    // MARK: - 구매 내역
    
    /// 모든 구매 내역을 가져옵니다.
    func getPurchaseHistory() async -> [Transaction] {
        var transactions: [Transaction] = []
        
        for await result in Transaction.all {
            if let transaction = try? checkVerification(result) {
                transactions.append(transaction)
            }
        }
        
        // 최신순 정렬
        return transactions.sorted { $0.purchaseDate > $1.purchaseDate }
    }
    
    // MARK: - Private 메서드
    
    /// 트랜잭션 업데이트 감시를 시작합니다.
    private func startTransactionListener() {
        transactionListener = Task.detached { [weak self] in
            // 트랜잭션 업데이트 감시 (백그라운드에서 완료된 구매 등)
            for await result in Transaction.updates {
                guard let self = self else { return }
                
                if let transaction = try? await self.checkVerification(result) {
                    await self.handlePurchase(transaction)
                    await transaction.finish()
                }
            }
        }
    }
    
    /// 영수증을 검증합니다.
    private func checkVerification<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw PurchaseError.verificationFailed
        }
    }
    
    /// 구매 완료를 처리합니다.
    private func handlePurchase(_ transaction: Transaction) async {
        // 구매한 상품 ID 추가
        purchasedProductIDs.insert(transaction.productID)
        
        // 구독인 경우 상태 업데이트
        if transaction.productType == .autoRenewable {
            await updateSubscriptionStatus()
        }
    }
    
    /// 구매한 상품 목록을 업데이트합니다.
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        // 현재 자격이 있는 모든 트랜잭션 확인
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerification(result) {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
        
        // 구독 상태도 업데이트
        await updateSubscriptionStatus()
    }
    
    /// 구독 상태를 업데이트합니다.
    private func updateSubscriptionStatus() async {
        // 자동 갱신 구독 상태 확인
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerification(result),
                  transaction.productType == .autoRenewable else {
                continue
            }
            
            // 구독 상태 확인
            if let expirationDate = transaction.expirationDate {
                subscriptionExpirationDate = expirationDate
                
                if expirationDate > Date() {
                    // 아직 유효한 구독
                    if transaction.revocationDate != nil {
                        subscriptionStatus = .revoked
                    } else {
                        subscriptionStatus = .active
                    }
                } else {
                    subscriptionStatus = .expired
                }
                return
            }
        }
        
        // 구독 없음
        subscriptionStatus = .none
        subscriptionExpirationDate = nil
    }
}

// MARK: - 테스트/디버그 지원
#if DEBUG
extension StoreManager {
    /// 테스트용: 프리미엄 상태 토글
    func togglePremiumForTesting() {
        if purchasedProductIDs.contains(ProductItem.ProductID.premiumUnlock) {
            purchasedProductIDs.remove(ProductItem.ProductID.premiumUnlock)
        } else {
            purchasedProductIDs.insert(ProductItem.ProductID.premiumUnlock)
        }
    }
    
    /// 테스트용: 구독 상태 설정
    func setSubscriptionStatusForTesting(_ status: SubscriptionStatus) {
        subscriptionStatus = status
    }
}
#endif
