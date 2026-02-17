import SwiftUI
import StoreKit

/// 오퍼 코드 시트 표시 (iOS 16+)
struct OfferCodeRedemptionDemo: View {
    @State private var showingRedeemSheet = false
    @State private var redemptionMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("프리미엄 구독")
                .font(.largeTitle.bold())
            
            // 오퍼 코드 버튼
            Button {
                showingRedeemSheet = true
            } label: {
                HStack {
                    Image(systemName: "ticket")
                    Text("오퍼 코드 사용")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if let message = redemptionMessage {
                Text(message)
                    .foregroundStyle(message.contains("성공") ? .green : .red)
            }
        }
        .padding()
        // iOS 16+: offerCodeRedemption modifier
        .offerCodeRedemption(isPresented: $showingRedeemSheet) { result in
            switch result {
            case .success:
                redemptionMessage = "✅ 코드 적용 성공!"
                // 구독 상태 새로고침
                Task {
                    await refreshSubscriptionStatus()
                }
            case .failure(let error):
                if case StoreKitError.userCancelled = error {
                    redemptionMessage = nil
                } else {
                    redemptionMessage = "❌ 오류: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func refreshSubscriptionStatus() async {
        // Transaction.currentEntitlements로 구독 상태 갱신
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                print("📦 활성 권한: \(transaction.productID)")
            }
        }
    }
}

// MARK: - 프로그래밍 방식 코드 입력 (iOS 14+)

/// AppStore에서 직접 코드 입력 화면 열기
struct LegacyOfferCodeRedemption {
    /// App Store 코드 입력 URL 열기
    /// iOS 14-15에서 사용 가능한 방식
    static func openAppStoreRedemption() {
        if let url = URL(string: "https://apps.apple.com/redeem") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - 오퍼 코드 관련 딥링크 처리

/// 외부에서 오퍼 코드로 앱 열기 처리
/// URL 형식: yourapp://redeem?code=ABCD-1234-EFGH
class OfferCodeDeepLinkHandler {
    
    func handle(url: URL) -> Bool {
        guard url.scheme == "yourapp",
              url.host == "redeem",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            return false
        }
        
        // 코드와 함께 오퍼 코드 시트 표시
        // 참고: presentOfferCodeRedeemSheet는 코드 자동 입력을 지원하지 않음
        // 사용자가 직접 코드를 입력해야 함
        NotificationCenter.default.post(
            name: .showOfferCodeSheet,
            object: nil,
            userInfo: ["code": code]
        )
        
        return true
    }
}

extension Notification.Name {
    static let showOfferCodeSheet = Notification.Name("showOfferCodeSheet")
}

// MARK: - 메인 앱에서 딥링크 처리 예시

struct OfferCodeApp: App {
    @State private var showingOfferCode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .offerCodeRedemption(isPresented: $showingOfferCode) { _ in }
                .onOpenURL { url in
                    if url.host == "redeem" {
                        showingOfferCode = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .showOfferCodeSheet)) { _ in
                    showingOfferCode = true
                }
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Premium App")
    }
}

#Preview {
    OfferCodeRedemptionDemo()
}
