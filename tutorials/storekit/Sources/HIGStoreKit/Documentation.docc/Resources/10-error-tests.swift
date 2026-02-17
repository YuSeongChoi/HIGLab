import XCTest
import StoreKitTest
@testable import YourApp

/// 에러 시나리오 테스트
final class ErrorTests: StoreKitTestCase {
    
    // MARK: - 결제 실패 테스트
    
    func testPaymentNotAllowed() async throws {
        // Given
        session.failTransactionsEnabled = true
        session.failureError = .paymentNotAllowed
        
        try await waitForProducts()
        let product = storeManager.products.first!
        
        // When/Then
        do {
            _ = try await storeManager.purchase(product)
            XCTFail("Expected error")
        } catch let error as StoreError {
            XCTAssertEqual(error, .paymentNotAllowed)
        }
    }
    
    func testNetworkError() async throws {
        // Given
        session.failTransactionsEnabled = true
        session.failureError = .networkError(URLError(.notConnectedToInternet))
        
        try await waitForProducts()
        let product = storeManager.products.first!
        
        // When/Then
        do {
            _ = try await storeManager.purchase(product)
            XCTFail("Expected error")
        } catch let error as StoreError {
            XCTAssertEqual(error, .networkError)
        }
    }
    
    // MARK: - 환불 테스트
    
    func testRefund() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.basic.monthly" }!
        let result = try await storeManager.purchase(product)
        
        guard case .success(let transaction) = result else {
            XCTFail("Purchase failed")
            return
        }
        
        // When - 환불 시뮬레이션
        try session.refundTransaction(identifier: UInt64(transaction.id))
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        let hasEntitlement = await storeManager.hasActiveSubscription()
        XCTAssertFalse(hasEntitlement, "환불 후 권한이 제거되어야 함")
    }
    
    func testRevocation() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first!
        let result = try await storeManager.purchase(product)
        
        guard case .success(let transaction) = result else {
            XCTFail("Purchase failed")
            return
        }
        
        // When - Revocation 시뮬레이션
        try session.revokeTransaction(identifier: UInt64(transaction.id))
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        let transactions = await storeManager.getAllTransactions()
        let revokedTransaction = transactions.first { $0.id == transaction.id }
        XCTAssertNotNil(revokedTransaction?.revocationDate)
    }
    
    // MARK: - 복원 테스트
    
    func testRestorePurchases() async throws {
        // Given - 이전에 구매한 상품이 있다고 가정
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.lifetime" }!
        _ = try await storeManager.purchase(product)
        
        // 새 StoreManager로 복원 시뮬레이션
        let newStoreManager = StoreManager()
        
        // When
        try await newStoreManager.restorePurchases()
        
        // Then
        let hasEntitlement = await newStoreManager.hasEntitlement(for: product.id)
        XCTAssertTrue(hasEntitlement, "복원 후 권한이 있어야 함")
    }
    
    // MARK: - Ask to Buy 테스트
    
    func testAskToBuy() async throws {
        // Given
        session.askToBuyEnabled = true
        try await waitForProducts()
        let product = storeManager.products.first!
        
        // When
        let result = try await storeManager.purchase(product)
        
        // Then
        switch result {
        case .pending:
            // Ask to Buy는 pending 상태로 반환
            XCTAssertTrue(true)
        default:
            XCTFail("Expected pending state for Ask to Buy")
        }
        
        // 부모 승인 시뮬레이션
        try session.approveAskToBuyTransaction(identifier: 1)
    }
    
    // MARK: - 중복 구매 방지 테스트
    
    func testPreventDuplicatePurchase() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.lifetime" }!
        
        // First purchase
        _ = try await storeManager.purchase(product)
        
        // When - 동일 상품 재구매 시도
        let duplicateResult = try await storeManager.purchase(product)
        
        // Then - 비소모성은 기존 트랜잭션 반환
        switch duplicateResult {
        case .success(let transaction):
            // 같은 상품의 기존 트랜잭션
            XCTAssertEqual(transaction.productID, product.id)
        default:
            break
        }
    }
}
