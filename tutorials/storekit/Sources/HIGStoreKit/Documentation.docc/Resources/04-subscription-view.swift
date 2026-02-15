import SwiftUI

struct SubscriptionStatusView: View {
    let status: SubscriptionStatus
    
    var body: some View {
        VStack(spacing: 16) {
            // 구독 상태 배지
            HStack {
                Image(systemName: status.isActive ? "checkmark.seal.fill" : "xmark.seal")
                    .foregroundStyle(status.isActive ? .green : .red)
                Text(status.isActive ? "프리미엄 활성" : "프리미엄 만료")
                    .font(.headline)
            }
            
            if let days = status.daysRemaining, days > 0 {
                Text("\(days)일 후 갱신")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 구독 관리 버튼
            Button("구독 관리") {
                openSubscriptionManagement()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    func openSubscriptionManagement() {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}
