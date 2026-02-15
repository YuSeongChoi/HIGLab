import StoreKit

extension StoreManager {
    
    // MARK: - 트랜잭션 리스너
    // 앱 시작 시 호출해야 함
    
    func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            // 백그라운드에서 트랜잭션 업데이트 청취
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // 구매 상태 업데이트
                    await self.updatePurchasedProducts()
                    
                    // 트랜잭션 완료
                    await transaction.finish()
                } catch {
                    print("트랜잭션 처리 실패: \(error)")
                }
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}
