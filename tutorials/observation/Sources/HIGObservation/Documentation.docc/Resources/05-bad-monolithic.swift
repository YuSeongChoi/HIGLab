import SwiftUI
import Observation

/// ❌ 안티패턴: 하나의 큰 뷰에서 모든 것을 처리

@Observable
class BigStore {
    var userName: String = "홍길동"
    var userEmail: String = "hong@example.com"
    var cartCount: Int = 0
    var cartTotal: Double = 0
    var isLoggedIn: Bool = true
    var notifications: [String] = []
}

/// ❌ 모든 상태를 하나의 뷰에서 사용
struct MonolithicView: View {
    var store: BigStore
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack(spacing: 20) {
            // 사용자 정보 영역
            VStack {
                Text(store.userName)
                    .font(.title)
                Text(store.userEmail)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // 카트 정보 영역
            HStack {
                Text("장바구니: \(store.cartCount)개")
                Spacer()
                Text(store.cartTotal, format: .currency(code: "KRW"))
            }
            
            Divider()
            
            // 알림 영역
            if !store.notifications.isEmpty {
                VStack {
                    ForEach(store.notifications, id: \.self) { notification in
                        Text(notification)
                    }
                }
            }
        }
        .padding()
    }
}

// 💥 문제점:
// - cartCount만 바뀌어도 전체 VStack이 다시 그려짐
// - userName만 바뀌어도 카트, 알림 영역도 재계산
// - notifications 배열 하나만 바뀌어도 전체 뷰 업데이트

// 이런 "God View" 패턴은 피하세요!
