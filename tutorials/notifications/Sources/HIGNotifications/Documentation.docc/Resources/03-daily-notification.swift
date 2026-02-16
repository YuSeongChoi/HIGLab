import UserNotifications

// 매일 오전 8시 30분에 알림

var dailyComponents = DateComponents()
dailyComponents.hour = 8
dailyComponents.minute = 30
// year, month, day를 생략하면 "매일" 의미

let dailyTrigger = UNCalendarNotificationTrigger(
    dateMatching: dailyComponents,
    repeats: true  // 반복 활성화
)

let content = UNMutableNotificationContent()
content.title = "좋은 아침이에요! ☀️"
content.body = "오늘 하루도 화이팅하세요"
content.sound = .default

let request = UNNotificationRequest(
    identifier: "daily-morning-greeting",
    content: content,
    trigger: dailyTrigger
)
