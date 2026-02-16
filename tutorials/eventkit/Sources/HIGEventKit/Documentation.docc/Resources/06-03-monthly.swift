import EventKit

// 매월 반복 (같은 날짜)
let monthlyRule = EKRecurrenceRule(
    recurrenceWith: .monthly,
    interval: 1,
    end: nil
)

// 3개월마다 반복
let quarterlyRule = EKRecurrenceRule(
    recurrenceWith: .monthly,
    interval: 3,
    end: nil
)
