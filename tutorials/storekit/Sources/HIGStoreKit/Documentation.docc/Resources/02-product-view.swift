import SwiftUI
import StoreKit

struct ProductListView: View {
    @StateObject var store = StoreManager()
    
    var body: some View {
        List(store.products) { product in
            ProductRow(product: product)
        }
        .task {
            await store.loadProducts()
        }
    }
}

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                
                Text(product.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 현지 통화로 자동 포맷
            Text(product.displayPrice)
                .font(.headline)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 8)
    }
}
