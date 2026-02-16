import UserNotifications

// UNNotificationRequest의 구조
// - identifier: 고유 식별자 (나중에 수정/삭제에 사용)
// - content: 알림 내용
// - trigger: 발동 조건 (nil이면 즉시 전달)

let request = UNNotificationRequest(
    identifier: UUID().uuidString,  // 고유 ID 생성
    content: content,
    trigger: trigger
)

// identifier 활용 예시
// - "reminder-\(reminderID)" : 특정 리마인더의 알림
// - "daily-water-reminder"   : 반복 알림 (업데이트/취소용)
// - UUID().uuidString        : 일회성 알림
