import StoreKit

extension StoreManager {
    
    // MARK: - 구매 처리
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // 서명 검증
            guard case .verified(let transaction) = verification else {
                throw StoreError.verificationFailed
            }
            
            // 트랜잭션 완료 처리
            await transaction.finish()
            
            // 구매 상태 업데이트
            purchasedProductIDs.insert(transaction.productID)
            
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            // 부모 승인 대기 등
            return nil
            
        @unknown default:
            return nil
        }
    }
}

enum StoreError: Error {
    case verificationFailed
    case purchaseFailed
}
