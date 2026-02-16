import UserNotifications

// UNTimeIntervalNotificationTrigger
// 지정한 시간(초) 후에 알림 발생

// 30초 후 1회 알림
let trigger30sec = UNTimeIntervalNotificationTrigger(
    timeInterval: 30,
    repeats: false
)

// 5분 후 1회 알림
let trigger5min = UNTimeIntervalNotificationTrigger(
    timeInterval: 5 * 60,
    repeats: false
)

// 1시간마다 반복 알림
// ⚠️ repeats: true는 최소 60초 이상이어야 함
let triggerHourly = UNTimeIntervalNotificationTrigger(
    timeInterval: 60 * 60,
    repeats: true
)
