import Foundation
import StoreKit

@Observable
final class StoreManager {
    private(set) var products: [Product] = []
    private(set) var purchasedSubscriptions: [Product] = []
    private(set) var subscriptionStatus: SubscriptionStatus = .notSubscribed
    
    enum SubscriptionStatus {
        case notSubscribed
        case subscribed(expirationDate: Date?)
        case expired
    }
    
    // Product IDs - App Store Connect에서 설정
    private let subscriptionProductIds = [
        "com.higlab.ecommerce.premium.monthly",
        "com.higlab.ecommerce.premium.yearly"
    ]
    
    init() {
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
        
        // 거래 업데이트 리스닝
        listenForTransactions()
    }
    
    // MARK: - Load Products
    @MainActor
    func loadProducts() async {
        do {
            let storeProducts = try await StoreKit.Product.products(for: subscriptionProductIds)
            products = storeProducts.map { storeProduct in
                Product(
                    id: storeProduct.id,
                    name: storeProduct.displayName,
                    description: storeProduct.description,
                    price: storeProduct.price,
                    imageName: "crown.fill",
                    category: .accessories
                )
            }
        } catch {
            print("상품 로드 실패: \(error)")
        }
    }
    
    // MARK: - Purchase
    @MainActor
    func purchase(_ productId: String) async throws -> StoreKit.Transaction? {
        guard let product = try await StoreKit.Product.products(for: [productId]).first else {
            return nil
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateSubscriptionStatus()
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Subscription Status
    @MainActor
    func updateSubscriptionStatus() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    subscriptionStatus = .subscribed(expirationDate: transaction.expirationDate)
                    return
                }
            }
        }
        subscriptionStatus = .notSubscribed
    }
    
    // MARK: - Restore
    @MainActor
    func restore() async throws {
        try await AppStore.sync()
        await updateSubscriptionStatus()
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() {
        Task.detached {
            for await result in StoreKit.Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    enum StoreError: Error {
        case failedVerification
    }
}
