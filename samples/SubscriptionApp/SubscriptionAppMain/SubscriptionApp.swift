import SwiftUI

// MARK: - 앱 진입점
// StoreKit 구독을 사용하는 샘플 앱

/// 앱의 메인 진입점
@main
struct SubscriptionApp: App {
    
    // MARK: - 상태 객체
    
    /// 구독 관리자 (앱 전체에서 공유)
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    /// 자격 관리자 (앱 전체에서 공유)
    @StateObject private var entitlementManager = EntitlementManager.shared
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 환경 객체로 주입하여 하위 뷰에서 접근 가능
                .environmentObject(subscriptionManager)
                .environmentObject(entitlementManager)
                // 앱 활성화 시 구독 상태 새로고침
                .task {
                    await subscriptionManager.updateSubscriptionStatus()
                }
                // 앱이 포그라운드로 돌아올 때마다 상태 확인
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification
                )) { _ in
                    Task {
                        await subscriptionManager.updateSubscriptionStatus()
                    }
                }
        }
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(EntitlementManager.shared)
}
