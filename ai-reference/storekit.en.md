# StoreKit 2 AI Reference

> In-app purchase and subscription implementation guide. Read this document to implement StoreKit 2.

## Overview

StoreKit 2 is a modern in-app purchase framework based on Swift Concurrency.
You can implement subscriptions, consumable/non-consumable products, promotions, and more.

## Required Import

```swift
import StoreKit
```

## Core Components

### 1. Product Retrieval

```swift
// Query by product IDs
let productIDs = ["premium_monthly", "premium_yearly", "remove_ads"]
let products = try await Product.products(for: productIDs)

for product in products {
    print("\(product.displayName): \(product.displayPrice)")
}
```

### 2. Purchase Handling

```swift
func purchase(_ product: Product) async throws -> Transaction? {
    let result = try await product.purchase()
    
    switch result {
    case .success(let verification):
        // Receipt verification
        let transaction = try checkVerified(verification)
        
        // Deliver content
        await deliverProduct(transaction)
        
        // Finish transaction
        await transaction.finish()
        return transaction
        
    case .userCancelled:
        return nil
        
    case .pending:
        // Waiting for approval (e.g., Family Sharing)
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

### 3. Transaction Listener

```swift
// Call at app launch
func listenForTransactions() -> Task<Void, Error> {
    return Task.detached {
        for await result in Transaction.updates {
            do {
                let transaction = try self.checkVerified(result)
                await self.deliverProduct(transaction)
                await transaction.finish()
            } catch {
                print("Transaction failed: \(error)")
            }
        }
    }
}
```

## Complete Working Example: Subscription App

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
    
    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: [
                "premium_monthly",
                "premium_yearly"
            ])
            products.sort { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Check Purchase Status
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
    
    // MARK: - Purchase
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
    
    // MARK: - Restore Purchases
    func restore() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    // MARK: - Premium Status
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    // MARK: - Transaction Listener
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
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                    
                    Text("Premium Subscription")
                        .font(.largeTitle.bold())
                    
                    Text("Unlock unlimited access to all features")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Product list
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
                
                // Restore button
                Button("Restore Purchases") {
                    Task {
                        try? await store.restore()
                    }
                }
                .font(.footnote)
                
                // Terms
                Text("Subscription automatically renews. Cancel anytime.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
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

## Checking Subscription Status

```swift
// Current subscription status
for await result in Transaction.currentEntitlements {
    if case .verified(let transaction) = result {
        print("Active subscription: \(transaction.productID)")
        print("Expiration date: \(transaction.expirationDate ?? Date())")
    }
}

// Check if subscribed to specific product
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

## Opening Subscription Management

```swift
// Subscription management sheet (iOS 15+)
.manageSubscriptionsSheet(isPresented: $showManageSubscriptions)

// Refund request sheet
.refundRequestSheet(for: transactionID, isPresented: $showRefund)
```

## StoreKit Configuration File

Define test products in Xcode:

1. File > New > File > StoreKit Configuration File
2. Add products (+ button)
3. Scheme > Edit Scheme > Options > Select StoreKit Configuration

```json
// Example product structure
{
  "identifier": "premium_monthly",
  "type": "Auto-Renewable Subscription",
  "displayName": "Monthly Subscription",
  "description": "Auto-renews monthly",
  "price": 4.99,
  "subscriptionGroupID": "premium"
}
```

## Important Notes

1. **Real device testing required**: Simulator has limitations
2. **Sandbox account**: Test Apple ID required
3. **Receipt verification**: Server-side verification recommended
4. **Transaction.finish()**: Must be called (otherwise repurchase not possible)
5. **currentEntitlements**: Returns only active subscriptions/purchases

## App Store Connect Setup

1. App > In-App Purchases > Add Product
2. Create subscription group (for subscriptions)
3. Set pricing and availability
4. In-app purchase promotions (optional)
