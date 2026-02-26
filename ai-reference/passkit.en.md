# PassKit AI Reference

> Apple Pay and Wallet integration guide. You can generate PassKit code by reading this document.

## Overview

PassKit is a framework for managing Apple Pay payments and Wallet passes (boarding passes, tickets, etc.).
It provides convenient payment UI and pass addition functionality.

## Required Import

```swift
import PassKit
```

## Project Setup

1. **Capabilities**: Add Apple Pay
2. **Merchant ID**: Create in Apple Developer
3. **Payment Processing Certificate**: Certificate for payment processing

## Core Components

### 1. Check Apple Pay Support

```swift
// Check if Apple Pay is available
let canMakePayments = PKPaymentAuthorizationController.canMakePayments()

// Check specific card network support
let networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
let canMakePaymentsWithNetworks = PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
```

### 2. Create Payment Request

```swift
func createPaymentRequest() -> PKPaymentRequest {
    let request = PKPaymentRequest()
    
    // Merchant information
    request.merchantIdentifier = "merchant.com.yourcompany.app"
    request.merchantCapabilities = [.capability3DS, .capabilityDebit, .capabilityCredit]
    
    // Supported cards
    request.supportedNetworks = [.visa, .masterCard, .amex]
    
    // Country and currency
    request.countryCode = "KR"
    request.currencyCode = "KRW"
    
    // Payment items
    request.paymentSummaryItems = [
        PKPaymentSummaryItem(label: "Product A", amount: NSDecimalNumber(value: 10000)),
        PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(value: 3000)),
        PKPaymentSummaryItem(label: "My Store", amount: NSDecimalNumber(value: 13000), type: .final)
    ]
    
    return request
}
```

### 3. Apple Pay Button

```swift
import SwiftUI
import PassKit

struct ApplePayButton: UIViewRepresentable {
    let action: () -> Void
    
    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func buttonTapped() {
            action()
        }
    }
}
```

## Complete Working Example

```swift
import SwiftUI
import PassKit

// MARK: - Cart Item
struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Decimal
    var quantity: Int
    
    var total: Decimal {
        price * Decimal(quantity)
    }
}

// MARK: - Payment Manager
@Observable
class PaymentManager: NSObject {
    var cartItems: [CartItem] = []
    var paymentStatus: PaymentStatus = .idle
    
    enum PaymentStatus {
        case idle
        case processing
        case success
        case failed(Error)
    }
    
    var canUseApplePay: Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    }
    
    private let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
    private let merchantIdentifier = "merchant.com.example.app"
    
    var subtotal: Decimal {
        cartItems.reduce(0) { $0 + $1.total }
    }
    
    var shippingCost: Decimal {
        subtotal >= 50000 ? 0 : 3000
    }
    
    var total: Decimal {
        subtotal + shippingCost
    }
    
    func startPayment() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.merchantCapabilities = [.capability3DS, .capabilityDebit, .capabilityCredit]
        request.supportedNetworks = supportedNetworks
        request.countryCode = "KR"
        request.currencyCode = "KRW"
        
        // Configure payment items
        var summaryItems: [PKPaymentSummaryItem] = cartItems.map { item in
            PKPaymentSummaryItem(
                label: "\(item.name) x\(item.quantity)",
                amount: NSDecimalNumber(decimal: item.total)
            )
        }
        
        if shippingCost > 0 {
            summaryItems.append(PKPaymentSummaryItem(
                label: "Shipping",
                amount: NSDecimalNumber(decimal: shippingCost)
            ))
        }
        
        summaryItems.append(PKPaymentSummaryItem(
            label: "My Store",
            amount: NSDecimalNumber(decimal: total),
            type: .final
        ))
        
        request.paymentSummaryItems = summaryItems
        
        // Show payment sheet
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller?.delegate = self
        controller?.present()
        
        paymentStatus = .processing
    }
}

extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, 
                                        didAuthorizePayment payment: PKPayment, 
                                        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Send payment token to server
        let token = payment.token.paymentData
        
        // In a real app, call server API
        Task {
            do {
                // let result = try await PaymentAPI.process(token: token)
                
                // Simulate success
                try await Task.sleep(for: .seconds(1))
                
                await MainActor.run {
                    paymentStatus = .success
                }
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            } catch {
                await MainActor.run {
                    paymentStatus = .failed(error)
                }
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }
}

// MARK: - Views
struct CheckoutView: View {
    @State private var paymentManager = PaymentManager()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Cart list
                List {
                    ForEach(paymentManager.cartItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(item.quantity) items")
                                .foregroundStyle(.secondary)
                            Text("₩\(NSDecimalNumber(decimal: item.total).intValue)")
                        }
                    }
                }
                
                // Summary
                VStack(spacing: 8) {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("₩\(NSDecimalNumber(decimal: paymentManager.subtotal).intValue)")
                    }
                    
                    HStack {
                        Text("Shipping")
                        Spacer()
                        Text(paymentManager.shippingCost > 0 ? "₩\(NSDecimalNumber(decimal: paymentManager.shippingCost).intValue)" : "Free")
                    }
                    .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("₩\(NSDecimalNumber(decimal: paymentManager.total).intValue)")
                            .font(.headline)
                    }
                }
                .padding()
                .background(.regularMaterial)
                
                // Apple Pay button
                if paymentManager.canUseApplePay {
                    ApplePayButton {
                        paymentManager.startPayment()
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                } else {
                    Button("Other Payment Method") {
                        // Alternative payment
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Checkout")
            .onAppear {
                // Sample data
                paymentManager.cartItems = [
                    CartItem(name: "Product A", price: 15000, quantity: 2),
                    CartItem(name: "Product B", price: 8000, quantity: 1)
                ]
            }
            .alert("Payment Complete", isPresented: .constant(paymentManager.paymentStatus == .success)) {
                Button("OK") {
                    paymentManager.paymentStatus = .idle
                }
            }
        }
    }
}

// Equatable for payment status comparison
extension PaymentManager.PaymentStatus: Equatable {
    static func == (lhs: PaymentManager.PaymentStatus, rhs: PaymentManager.PaymentStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.processing, .processing), (.success, .success):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
```

## Advanced Patterns

### 1. Add Wallet Pass

```swift
func addPassToWallet(passData: Data) {
    guard let pass = try? PKPass(data: passData) else { return }
    
    let library = PKPassLibrary()
    
    if library.containsPass(pass) {
        // Already added
        return
    }
    
    let controller = PKAddPassesViewController(pass: pass)
    // present controller
}

// SwiftUI
struct AddToWalletButton: View {
    let passURL: URL
    
    var body: some View {
        PKAddPassButton(.add) {
            // Pass addition logic
        }
    }
}
```

### 2. Shipping Options

```swift
func createRequestWithShipping() -> PKPaymentRequest {
    let request = createPaymentRequest()
    
    request.requiredShippingContactFields = [.postalAddress, .name, .phoneNumber]
    request.requiredBillingContactFields = [.postalAddress]
    
    request.shippingMethods = [
        PKShippingMethod(label: "Standard Shipping", amount: NSDecimalNumber(value: 3000)),
        PKShippingMethod(label: "Express Shipping", amount: NSDecimalNumber(value: 5000))
    ]
    request.shippingMethods?[0].identifier = "standard"
    request.shippingMethods?[1].identifier = "express"
    
    return request
}

// Handle shipping method change in delegate
func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                    didSelect shippingMethod: PKShippingMethod,
                                    handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
    // Recalculate total based on shipping cost
    let newItems = calculateItems(with: shippingMethod)
    completion(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: newItems))
}
```

### 3. Subscription Payment

```swift
let recurringItem = PKRecurringPaymentSummaryItem(
    label: "Monthly Subscription",
    amount: NSDecimalNumber(value: 9900)
)
recurringItem.intervalUnit = .month
recurringItem.intervalCount = 1
recurringItem.startDate = Date()
recurringItem.endDate = nil  // Indefinite

request.paymentSummaryItems = [recurringItem]
request.recurringPaymentRequest = PKRecurringPaymentRequest(
    paymentDescription: "Monthly Premium Subscription",
    regularBilling: recurringItem,
    managementURL: URL(string: "https://example.com/manage")!
)
```

## Notes

1. **Simulator Testing**
   - Apple Pay can only be fully tested on real devices
   - Only UI can be verified on simulator

2. **Merchant ID Setup**
   - Must be created in Apple Developer
   - Add to Xcode Capabilities

3. **Payment Token Handling**
   - Send `PKPayment.token.paymentData` to server
   - Server forwards to payment processor (Stripe, Toss, etc.)

4. **Error Handling**
   ```swift
   switch payment.token.paymentMethod.type {
   case .debit:
       // Debit card
   case .credit:
       // Credit card
   default:
       break
   }
   ```
