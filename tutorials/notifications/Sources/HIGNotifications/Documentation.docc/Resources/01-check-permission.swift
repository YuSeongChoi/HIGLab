import UserNotifications

extension NotificationManager {
    /// 상세 권한 설정을 확인합니다
    func checkDetailedSettings() async -> NotificationPermissions {
        let settings = await center.notificationSettings()
        
        return NotificationPermissions(
            alertEnabled: settings.alertSetting == .enabled,
            soundEnabled: settings.soundSetting == .enabled,
            badgeEnabled: settings.badgeSetting == .enabled,
            lockScreenEnabled: settings.lockScreenSetting == .enabled,
            notificationCenterEnabled: settings.notificationCenterSetting == .enabled
        )
    }
}

struct NotificationPermissions {
    let alertEnabled: Bool
    let soundEnabled: Bool
    let badgeEnabled: Bool
    let lockScreenEnabled: Bool
    let notificationCenterEnabled: Bool
    
    var allEnabled: Bool {
        alertEnabled && soundEnabled && badgeEnabled
    }
}
