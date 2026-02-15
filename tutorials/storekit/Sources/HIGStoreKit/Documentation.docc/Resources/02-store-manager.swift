import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    // 상품 ID (App Store Connect에서 설정)
    let productIDs = [
        "com.example.premium.monthly",
        "com.example.premium.yearly"
    ]
    
    // MARK: - 상품 로딩
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            
            // 가격순 정렬
            products.sort { $0.price < $1.price }
            
            print("상품 \(products.count)개 로딩 완료")
        } catch {
            print("상품 로딩 실패: \(error)")
        }
    }
    
    // MARK: - 구매 상태 확인
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            purchasedProductIDs.insert(transaction.productID)
        }
    }
}
