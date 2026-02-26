import SwiftUI
import SwiftData

@main
struct EcommerceAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CartItem.self, Order.self])
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProductListView()
                .tabItem {
                    Label("상품", systemImage: "square.grid.2x2")
                }
                .tag(0)
            
            CartView()
                .tabItem {
                    Label("장바구니", systemImage: "cart")
                }
                .tag(1)
            
            SubscriptionView()
                .tabItem {
                    Label("프리미엄", systemImage: "crown")
                }
                .tag(2)
            
            OrderHistoryView()
                .tabItem {
                    Label("주문내역", systemImage: "list.clipboard")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CartItem.self, Order.self], inMemory: true)
}
