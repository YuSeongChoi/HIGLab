import SwiftUI
import Observation

/// ✅ 권장 패턴: 작은 뷰로 분리

@Observable
class WellStructuredStore {
    var userName: String = "홍길동"
    var userEmail: String = "hong@example.com"
    var cartCount: Int = 0
    var cartTotal: Double = 0
    var isLoggedIn: Bool = true
    var notifications: [String] = []
}

// ✅ 사용자 정보만 담당하는 뷰
struct UserInfoSection: View {
    var store: WellStructuredStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack {
            Text(store.userName) // userName만 추적
                .font(.title)
            Text(store.userEmail) // userEmail만 추적
                .foregroundStyle(.secondary)
        }
    }
}

// ✅ 카트 정보만 담당하는 뷰
struct CartInfoSection: View {
    var store: WellStructuredStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        HStack {
            Text("장바구니: \(store.cartCount)개") // cartCount만 추적
            Spacer()
            Text(store.cartTotal, format: .currency(code: "KRW")) // cartTotal만 추적
        }
    }
}

// ✅ 알림만 담당하는 뷰
struct NotificationsSection: View {
    var store: WellStructuredStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        if !store.notifications.isEmpty { // notifications만 추적
            VStack {
                ForEach(store.notifications, id: \.self) { notification in
                    Text(notification)
                }
            }
        }
    }
}

// ✅ 조합 뷰 - 자식 뷰들을 배치만 함
struct WellStructuredView: View {
    var store: WellStructuredStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack(spacing: 20) {
            UserInfoSection(store: store)
            Divider()
            CartInfoSection(store: store)
            Divider()
            NotificationsSection(store: store)
        }
        .padding()
    }
}

// ✅ 결과:
// - cartCount 변경 → CartInfoSection만 업데이트
// - userName 변경 → UserInfoSection만 업데이트
// - notifications 변경 → NotificationsSection만 업데이트
// - 부모 WellStructuredView는 거의 업데이트되지 않음!
