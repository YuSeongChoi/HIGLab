import SwiftUI
import StoreKit

/// 구독 변경 UI
struct SubscriptionChangeView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var availablePlans: [Product] = []
    @State private var selectedProduct: Product?
    @State private var showUpgradeConfirm = false
    
    var body: some View {
        List {
            Section("현재 플랜") {
                if let transaction = subscriptionManager.activeTransaction {
                    CurrentPlanRow(transaction: transaction)
                }
            }
            
            Section("다른 플랜으로 변경") {
                ForEach(availablePlans, id: \.id) { product in
                    PlanRow(
                        product: product,
                        isCurrentPlan: isCurrentPlan(product),
                        onSelect: { selectPlan(product) }
                    )
                }
            }
        }
        .navigationTitle("플랜 변경")
        .sheet(isPresented: $showUpgradeConfirm) {
            if let product = selectedProduct {
                UpgradeConfirmView(product: product)
            }
        }
        .task {
            await loadAvailablePlans()
        }
    }
    
    private func isCurrentPlan(_ product: Product) -> Bool {
        subscriptionManager.activeTransaction?.productID == product.id
    }
    
    private func selectPlan(_ product: Product) {
        selectedProduct = product
        showUpgradeConfirm = true
    }
    
    private func loadAvailablePlans() async {
        let productIDs = [
            "com.example.basic.monthly",
            "com.example.premium.monthly",
            "com.example.ultimate.monthly"
        ]
        availablePlans = (try? await Product.products(for: productIDs)) ?? []
    }
}
