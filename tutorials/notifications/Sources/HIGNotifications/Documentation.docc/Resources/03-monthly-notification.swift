import UserNotifications

// 매월 1일 오전 10시에 알림
var firstDayComponents = DateComponents()
firstDayComponents.day = 1
firstDayComponents.hour = 10
firstDayComponents.minute = 0

let monthlyTrigger = UNCalendarNotificationTrigger(
    dateMatching: firstDayComponents,
    repeats: true
)

// 매월 15일 (월급날) 알림
var paydayComponents = DateComponents()
paydayComponents.day = 15
paydayComponents.hour = 9
paydayComponents.minute = 0

let paydayTrigger = UNCalendarNotificationTrigger(
    dateMatching: paydayComponents,
    repeats: true
)
