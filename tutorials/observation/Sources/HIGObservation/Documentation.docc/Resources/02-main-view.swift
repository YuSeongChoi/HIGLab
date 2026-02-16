import SwiftUI
import Observation

@main
struct CartFlowApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

/// 메인 탭 뷰
struct MainTabView: View {
    // ✅ @State로 CartStore 생성 - SwiftUI가 수명 관리
    @State private var store = CartStore()
    
    var body: some View {
        TabView {
            // 상품 목록 탭
            NavigationStack {
                ProductListView(store: store)
            }
            .tabItem {
                Label("쇼핑", systemImage: "bag")
            }
            
            // 장바구니 탭
            NavigationStack {
                CartView(store: store)
            }
            .tabItem {
                Label("카트", systemImage: "cart")
            }
            .badge(store.totalCount) // 뱃지도 자동 업데이트!
        }
    }
}

/// 장바구니 뷰 (간단한 버전)
struct CartView: View {
    var store: CartStore
    
    var body: some View {
        Group {
            if store.isEmpty {
                ContentUnavailableView(
                    "장바구니가 비어있어요",
                    systemImage: "cart",
                    description: Text("상품을 담아보세요!")
                )
            } else {
                List {
                    ForEach(store.items) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("×\(item.quantity)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            store.removeProduct(store.items[index])
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("총 금액")
                                .font(.headline)
                            Spacer()
                            Text(store.totalPrice, format: .currency(code: "KRW"))
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .navigationTitle("장바구니")
    }
}

#Preview {
    MainTabView()
}
