import UserNotifications

// 매월 첫 번째 월요일에 알림
var firstMondayComponents = DateComponents()
firstMondayComponents.weekday = 2           // 월요일
firstMondayComponents.weekdayOrdinal = 1    // 첫 번째
firstMondayComponents.hour = 10
firstMondayComponents.minute = 0

let firstMondayTrigger = UNCalendarNotificationTrigger(
    dateMatching: firstMondayComponents,
    repeats: true
)

// 매월 마지막 금요일에 알림
var lastFridayComponents = DateComponents()
lastFridayComponents.weekday = 6            // 금요일
lastFridayComponents.weekdayOrdinal = -1    // 마지막 (-1)
lastFridayComponents.hour = 18
lastFridayComponents.minute = 0

let lastFridayTrigger = UNCalendarNotificationTrigger(
    dateMatching: lastFridayComponents,
    repeats: true
)
