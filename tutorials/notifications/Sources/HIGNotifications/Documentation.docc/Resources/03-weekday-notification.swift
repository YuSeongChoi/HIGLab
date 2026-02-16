import UserNotifications

// 매주 월요일 오전 9시에 알림
// weekday: 1=일, 2=월, 3=화, 4=수, 5=목, 6=금, 7=토

var mondayComponents = DateComponents()
mondayComponents.weekday = 2  // 월요일
mondayComponents.hour = 9
mondayComponents.minute = 0

let mondayTrigger = UNCalendarNotificationTrigger(
    dateMatching: mondayComponents,
    repeats: true
)

// 매주 금요일 오후 6시에 알림
var fridayComponents = DateComponents()
fridayComponents.weekday = 6  // 금요일
fridayComponents.hour = 18
fridayComponents.minute = 0

let fridayTrigger = UNCalendarNotificationTrigger(
    dateMatching: fridayComponents,
    repeats: true
)
