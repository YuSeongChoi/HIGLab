import UserNotifications

// 매 시간마다 반복
let hourlyTrigger = UNTimeIntervalNotificationTrigger(
    timeInterval: 60 * 60,  // 3600초 = 1시간
    repeats: true
)

// 매 30분마다 반복
let halfHourlyTrigger = UNTimeIntervalNotificationTrigger(
    timeInterval: 30 * 60,  // 1800초 = 30분
    repeats: true
)

// ⚠️ 주의: 반복 간격은 최소 60초 이상이어야 합니다
// 아래 코드는 에러를 발생시킵니다:
// let invalidTrigger = UNTimeIntervalNotificationTrigger(
//     timeInterval: 30,  // 30초 - 반복에서는 허용되지 않음
//     repeats: true
// )
