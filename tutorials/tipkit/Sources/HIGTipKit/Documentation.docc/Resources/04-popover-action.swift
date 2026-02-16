import SwiftUI
import TipKit

struct NotificationTip: Tip {
    var title: Text { Text("알림 켜기") }
    var message: Text? { Text("중요한 소식을 놓치지 마세요") }
    var image: Image? { Image(systemName: "bell.badge") }
    
    // 팝오버에도 액션 버튼 표시됨
    var actions: [Action] {
        Action(id: "enable", title: "알림 켜기")
    }
}

struct PopoverWithActionView: View {
    let notificationTip = NotificationTip()
    
    var body: some View {
        Button {
            // 알림 설정 화면으로 이동
        } label: {
            Image(systemName: "bell")
                .font(.title2)
        }
        .popoverTip(notificationTip) { action in
            if action.id == "enable" {
                // 알림 활성화 처리
                enableNotifications()
            }
        }
    }
    
    func enableNotifications() {
        notificationTip.invalidate(reason: .actionPerformed)
    }
}
