# StoreKit 2 AI Reference

> 인앱결제 및 구독 구현 가이드. 이 문서를 읽고 StoreKit 2를 구현할 수 있습니다.

## 개요

StoreKit 2는 Swift Concurrency 기반의 현대적인 인앱결제 프레임워크입니다.
구독, 소모성/비소모성 상품, 프로모션 등을 구현할 수 있습니다.

## 필수 Import

```swift
import StoreKit
```

## 핵심 구성요소

### 1. Product 조회

```swift
// 상품 ID로 조회
let productIDs = ["premium_monthly", "premium_yearly", "remove_ads"]
let products = try await Product.products(for: productIDs)

for product in products {
    print("\(product.displayName): \(product.displayPrice)")
}
```

### 2. 구매 처리

```swift
func purchase(_ product: Product) async throws -> Transaction? {
    let result = try await product.purchase()
    
    switch result {
    case .success(let verification):
        // 영수증 검증
        let transaction = try checkVerified(verification)
        
        // 콘텐츠 제공
        await deliverProduct(transaction)
        
        // 트랜잭션 완료
        await transaction.finish()
        return transaction
        
    case .userCancelled:
        return nil
        
    case .pending:
        // 승인 대기 (가족 공유 등)
        return nil
        
    @unknown default:
        return nil
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
```

### 3. 트랜잭션 리스너

```swift
// 앱 시작 시 호출
func listenForTransactions() -> Task<Void, Error> {
    return Task.detached {
        for await result in Transaction.updates {
            do {
                let transaction = try self.checkVerified(result)
                await self.deliverProduct(transaction)
                await transaction.finish()
            } catch {
                print("트랜잭션 실패: \(error)")
            }
        }
    }
}
```

## 전체 작동 예제: 구독 앱

```swift
import SwiftUI
import StoreKit

// MARK: - Store Manager
@Observable
class StoreManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - 상품 로드
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: [
                "premium_monthly",
                "premium_yearly"
            ])
            products.sort { $0.price < $1.price }
        } catch {
            print("상품 로드 실패: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - 구매 상태 확인
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(transaction.productID)
            } else {
                purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    // MARK: - 구매
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            purchasedProductIDs.insert(transaction.productID)
            await transaction.finish()
            return true
            
        case .userCancelled, .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - 구매 복원
    func restore() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    // MARK: - 프리미엄 여부
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    // MARK: - 트랜잭션 리스너
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case verificationFailed
}

// MARK: - Paywall View
struct PaywallView: View {
    @Environment(StoreManager.self) var store
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 헤더
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                    
                    Text("Premium 구독")
                        .font(.largeTitle.bold())
                    
                    Text("모든 기능을 무제한으로 사용하세요")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // 상품 목록
                if store.isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 12) {
                        ForEach(store.products) { product in
                            ProductCard(product: product)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // 복원 버튼
                Button("구매 복원") {
                    Task {
                        try? await store.restore()
                    }
                }
                .font(.footnote)
                
                // 약관
                Text("구독은 자동 갱신됩니다. 언제든 취소할 수 있습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    @Environment(StoreManager.self) var store
    
    var body: some View {
        Button {
            Task {
                try? await store.purchase(product)
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.title3.bold())
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App
@main
struct SubscriptionApp: App {
    @State var store = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
```

## 구독 상태 확인

```swift
// 현재 구독 상태
for await result in Transaction.currentEntitlements {
    if case .verified(let transaction) = result {
        print("활성 구독: \(transaction.productID)")
        print("만료일: \(transaction.expirationDate ?? Date())")
    }
}

// 특정 상품 구독 여부
func isSubscribed(to productID: String) async -> Bool {
    for await result in Transaction.currentEntitlements {
        if case .verified(let transaction) = result,
           transaction.productID == productID {
            return true
        }
    }
    return false
}
```

## 구독 관리 열기

```swift
// 구독 관리 시트 (iOS 15+)
.manageSubscriptionsSheet(isPresented: $showManageSubscriptions)

// 환불 요청 시트
.refundRequestSheet(for: transactionID, isPresented: $showRefund)
```

## StoreKit Configuration 파일

Xcode에서 테스트용 상품 정의:

1. File > New > File > StoreKit Configuration File
2. 상품 추가 (+ 버튼)
3. Scheme > Edit Scheme > Options > StoreKit Configuration 선택

```json
// 예시 상품 구조
{
  "identifier": "premium_monthly",
  "type": "Auto-Renewable Subscription",
  "displayName": "월간 구독",
  "description": "매월 자동 갱신",
  "price": 4.99,
  "subscriptionGroupID": "premium"
}
```

## 주의사항

1. **실기기 테스트 필수**: 시뮬레이터는 제한적
2. **Sandbox 계정**: 테스트용 Apple ID 필요
3. **영수증 검증**: 서버 사이드 검증 권장
4. **Transaction.finish()**: 반드시 호출 (안 하면 재구매 불가)
5. **currentEntitlements**: 활성 구독/구매만 반환

## App Store Connect 설정

1. 앱 > 인앱 구입 > 상품 추가
2. 구독 그룹 생성 (구독의 경우)
3. 가격 및 가용성 설정
4. 앱 내 구입 프로모션 (선택)
