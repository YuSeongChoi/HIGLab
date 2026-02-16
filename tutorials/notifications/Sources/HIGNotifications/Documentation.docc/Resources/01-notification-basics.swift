import UserNotifications

// UNUserNotificationCenter는 모든 알림 작업의 중심입니다
// 싱글톤 패턴으로 앱 전체에서 하나의 인스턴스를 공유합니다

let center = UNUserNotificationCenter.current()

// 주요 역할:
// - 알림 권한 요청 및 확인
// - 로컬 알림 예약 및 관리
// - 푸시 알림 처리
// - 알림 카테고리/액션 등록
