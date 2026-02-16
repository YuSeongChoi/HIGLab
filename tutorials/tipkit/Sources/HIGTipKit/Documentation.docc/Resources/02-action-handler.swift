import SwiftUI
import TipKit

struct NotificationTip: Tip {
    var title: Text { Text("알림 설정") }
    var message: Text? { Text("알림을 켜면 중요한 업데이트를 놓치지 않아요") }
    
    var actions: [Action] {
        Action(id: "enable-now", title: "지금 켜기")
        Action(id: "go-to-settings", title: "설정으로 이동")
    }
}

struct ContentView: View {
    let notificationTip = NotificationTip()
    @State private var showSettings = false
    
    var body: some View {
        VStack {
            // TipView에 actionHandler 추가
            TipView(notificationTip) { action in
                // 액션 ID로 분기 처리
                switch action.id {
                case "enable-now":
                    enableNotifications()
                case "go-to-settings":
                    showSettings = true
                default:
                    break
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    func enableNotifications() {
        // 알림 활성화 로직
        print("알림 활성화!")
        
        // 사용자가 기능을 사용했으므로 팁 무효화
        notificationTip.invalidate(reason: .actionPerformed)
    }
}
