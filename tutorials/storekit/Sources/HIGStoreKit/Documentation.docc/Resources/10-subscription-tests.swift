import XCTest
import StoreKitTest
@testable import YourApp

/// 구독 갱신/만료 테스트
final class SubscriptionTests: StoreKitTestCase {
    
    func testSubscriptionRenewal() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.basic.monthly" }!
        _ = try await storeManager.purchase(product)
        
        // When - 갱신 시뮬레이션 (시간 빨리 감기)
        try session.expireSubscription(productIdentifier: product.id)
        
        // 트랜잭션 업데이트 대기
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then - 갱신 후에도 권한 유지
        let hasEntitlement = await storeManager.hasActiveSubscription()
        XCTAssertTrue(hasEntitlement)
    }
    
    func testSubscriptionExpiration() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.basic.monthly" }!
        _ = try await storeManager.purchase(product)
        
        // 자동 갱신 비활성화
        try session.disableAutoRenewForTransaction(identifier: 1)
        
        // When - 만료 시뮬레이션
        try session.expireSubscription(productIdentifier: product.id)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then - 만료 후 권한 없음
        let hasEntitlement = await storeManager.hasActiveSubscription()
        XCTAssertFalse(hasEntitlement)
    }
    
    func testSubscriptionUpgrade() async throws {
        // Given - Basic 구독 중
        try await waitForProducts()
        let basicProduct = storeManager.products.first { $0.id == "com.example.basic.monthly" }!
        let premiumProduct = storeManager.products.first { $0.id == "com.example.premium.monthly" }!
        
        _ = try await storeManager.purchase(basicProduct)
        
        // When - Premium으로 업그레이드
        let result = try await storeManager.purchase(premiumProduct)
        
        // Then
        switch result {
        case .success(let transaction):
            XCTAssertEqual(transaction.productID, premiumProduct.id)
            
            // 업그레이드 후 Basic 권한은 없어야 함
            let entitlements = await storeManager.currentEntitlements()
            XCTAssertFalse(entitlements.contains(basicProduct.id))
            XCTAssertTrue(entitlements.contains(premiumProduct.id))
        default:
            XCTFail("Expected success")
        }
    }
    
    func testGracePeriod() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.basic.monthly" }!
        _ = try await storeManager.purchase(product)
        
        // When - 결제 실패로 인한 유예 기간 진입
        session.failTransactionsEnabled = true
        session.failureError = .paymentNotAllowed
        
        try session.expireSubscription(productIdentifier: product.id)
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then - 유예 기간 중에는 여전히 권한 있음
        let status = await storeManager.subscriptionStatus()
        XCTAssertEqual(status, .gracePeriod)
    }
    
    func testBillingRetry() async throws {
        // Given
        try await waitForProducts()
        let product = storeManager.products.first { $0.id == "com.example.basic.monthly" }!
        _ = try await storeManager.purchase(product)
        
        // When - 결제 재시도 상태 시뮬레이션
        try session.forceRenewalOfSubscription(productIdentifier: product.id)
        
        // Then - 재시도 중 상태 확인
        let renewalInfo = try await storeManager.getRenewalInfo(for: product.id)
        XCTAssertNotNil(renewalInfo)
    }
}
