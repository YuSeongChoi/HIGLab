import EventKit

// 이벤트 시작 15분 전 알림
let alarm15Min = EKAlarm(relativeOffset: -15 * 60)

// 이벤트 시작 1시간 전 알림
let alarm1Hour = EKAlarm(relativeOffset: -60 * 60)

// 이벤트 시작 1일 전 알림
let alarm1Day = EKAlarm(relativeOffset: -24 * 60 * 60)
