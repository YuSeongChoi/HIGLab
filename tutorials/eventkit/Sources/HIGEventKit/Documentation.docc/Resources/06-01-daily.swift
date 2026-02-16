import EventKit

// 매일 반복
let dailyRule = EKRecurrenceRule(
    recurrenceWith: .daily,
    interval: 1,
    end: nil
)

// 2일마다 반복
let everyOtherDay = EKRecurrenceRule(
    recurrenceWith: .daily,
    interval: 2,
    end: nil
)
