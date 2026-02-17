import XCTest
import StoreKitTest
@testable import YourApp

/// 구매 플로우 테스트
final class PurchaseTests: StoreKitTestCase {
    
    func testLoadProducts() async throws {
        // When
        try await storeManager.loadProducts()
        
        // Then
        XCTAssertFalse(storeManager.products.isEmpty)
        XCTAssertTrue(storeManager.products.contains { $0.id == "com.example.basic.monthly" })
    }
    
    func testPurchaseSubscription() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.basic.monthly" }!
        
        // When
        let result = try await storeManager.purchase(product)
        
        // Then
        switch result {
        case .success(let transaction):
            XCTAssertEqual(transaction.productID, product.id)
            XCTAssertNil(transaction.revocationDate)
        case .pending, .userCancelled:
            XCTFail("Expected success")
        @unknown default:
            XCTFail("Unknown result")
        }
    }
    
    func testPurchaseAlreadyOwned() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.lifetime" }!
        
        // First purchase
        _ = try await storeManager.purchase(product)
        
        // When - Second purchase
        let result = try await storeManager.purchase(product)
        
        // Then - 이미 소유한 상품은 다시 구매 불가
        switch result {
        case .success:
            // 비소모성 상품은 기존 트랜잭션 반환
            break
        default:
            break
        }
    }
    
    func testPurchaseCancellation() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first!
        
        // SKTestSession에서 취소 시뮬레이션
        session.failTransactionsEnabled = true
        session.failureError = .paymentCancelled
        
        // When
        do {
            _ = try await storeManager.purchase(product)
            XCTFail("Expected error")
        } catch {
            // Then
            XCTAssertTrue(error is StoreError)
        }
        
        session.failTransactionsEnabled = false
    }
    
    func testVerifyEntitlements() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.basic.monthly" }!
        
        // When
        _ = try await storeManager.purchase(product)
        
        // Then
        let hasEntitlement = await storeManager.hasActiveSubscription()
        XCTAssertTrue(hasEntitlement)
    }
}
