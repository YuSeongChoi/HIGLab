import UserNotifications

// UNCalendarNotificationTrigger
// DateComponents로 정확한 날짜/시간 지정

// 오늘 오후 3시에 알림
var components = DateComponents()
components.hour = 15
components.minute = 0

let trigger = UNCalendarNotificationTrigger(
    dateMatching: components,
    repeats: false
)

// 특정 날짜와 시간에 알림
var specificDate = DateComponents()
specificDate.year = 2024
specificDate.month = 12
specificDate.day = 25
specificDate.hour = 9
specificDate.minute = 0

let christmasTrigger = UNCalendarNotificationTrigger(
    dateMatching: specificDate,
    repeats: false
)
