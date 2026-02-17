import StoreKit

/// 가족 공유 상태를 관리하는 매니저
@MainActor
class FamilyShareManager: ObservableObject {
    
    @Published var isFamilyShareEnabled = false
    @Published var ownershipType: Transaction.OwnershipType?
    
    /// 현재 사용자가 구매자인지 확인
    var isPurchaser: Bool {
        ownershipType == .purchased
    }
    
    /// 현재 사용자가 가족 공유 수혜자인지 확인
    var isFamilyMember: Bool {
        ownershipType == .familyShared
    }
    
    /// 구독의 소유권 타입 확인
    func checkOwnershipType() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.productType == .autoRenewable else {
                continue
            }
            
            self.ownershipType = transaction.ownershipType
            self.isFamilyShareEnabled = true
            return
        }
        
        // 유효한 구독 없음
        self.ownershipType = nil
        self.isFamilyShareEnabled = false
    }
    
    /// 가족 공유 해제 감지를 위한 트랜잭션 모니터링
    func startMonitoring() {
        Task {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                
                // revocationDate가 있으면 가족 공유 해제됨
                if transaction.revocationDate != nil {
                    await handleRevocation(transaction)
                } else {
                    await checkOwnershipType()
                }
            }
        }
    }
    
    private func handleRevocation(_ transaction: Transaction) async {
        self.ownershipType = nil
        self.isFamilyShareEnabled = false
        // UI에서 적절한 안내 표시
    }
}
