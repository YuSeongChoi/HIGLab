import SwiftUI

extension NotificationManager {
    /// 앱의 알림 설정 화면을 엽니다
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
