import EventKit

// 특정 시간에 알림
let specificDate = Calendar.current.date(
    from: DateComponents(
        year: 2024,
        month: 3,
        day: 15,
        hour: 9,
        minute: 0
    )
)!

let absoluteAlarm = EKAlarm(absoluteDate: specificDate)
