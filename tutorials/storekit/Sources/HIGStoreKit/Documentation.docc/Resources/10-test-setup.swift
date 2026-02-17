import XCTest
import StoreKitTest
@testable import YourApp

/// StoreKit 테스트 기본 설정
class StoreKitTestCase: XCTestCase {
    
    var session: SKTestSession!
    var storeManager: StoreManager!
    
    override func setUpWithError() throws {
        // StoreKit Configuration 파일 로드
        session = try SKTestSession(configurationFileNamed: "Products")
        
        // 테스트 세션 설정
        session.resetToDefaultState()
        session.disableDialogs = true          // 확인 다이얼로그 비활성화
        session.clearTransactions()            // 이전 트랜잭션 정리
        
        // 테스트 대상 초기화
        storeManager = StoreManager()
    }
    
    override func tearDownWithError() throws {
        session.clearTransactions()
        session = nil
        storeManager = nil
    }
    
    // MARK: - Helper Methods
    
    /// 상품 로드 대기
    func waitForProducts() async throws {
        try await storeManager.loadProducts()
    }
    
    /// 구매 시뮬레이션
    func simulatePurchase(productID: String) async throws {
        try await session.buyProduct(identifier: productID)
    }
    
    /// 구독 갱신 시뮬레이션
    func simulateRenewal(productID: String) throws {
        try session.expireSubscription(productIdentifier: productID)
    }
    
    /// 환불 시뮬레이션
    func simulateRefund(transactionID: UInt64) throws {
        try session.refundTransaction(identifier: transactionID)
    }
}
