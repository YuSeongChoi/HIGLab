import UserNotifications

// 알림의 3요소: Content, Trigger, Request

// 1. Content - 알림의 내용
let content = UNMutableNotificationContent()
content.title = "리마인더"
content.body = "오후 3시 미팅이 있습니다"
content.sound = .default

// 2. Trigger - 알림 발동 조건
let trigger = UNTimeIntervalNotificationTrigger(
    timeInterval: 60,  // 60초 후
    repeats: false
)

// 3. Request - Content + Trigger를 묶어서 요청
let request = UNNotificationRequest(
    identifier: UUID().uuidString,
    content: content,
    trigger: trigger
)
