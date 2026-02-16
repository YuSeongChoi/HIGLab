import UserNotifications

// 권한 옵션 종류

struct PermissionOptions {
    // 기본 옵션들
    static let basic: UNAuthorizationOptions = [
        .alert,  // 알림 배너/팝업 표시
        .sound,  // 알림 소리 재생
        .badge   // 앱 아이콘 배지 숫자
    ]
    
    // 추가 옵션들 (iOS 12+)
    static let advanced: UNAuthorizationOptions = [
        .alert,
        .sound,
        .badge,
        .provisional,     // 조용히 시범 알림 (사용자에게 묻지 않음)
        .criticalAlert    // 긴급 알림 (Apple 승인 필요)
    ]
    
    // iOS 15+ 추가 옵션
    // .providesAppNotificationSettings - 앱 내 알림 설정 화면 제공
}
