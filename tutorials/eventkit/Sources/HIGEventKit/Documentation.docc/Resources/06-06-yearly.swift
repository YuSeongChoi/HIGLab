import EventKit

// 매년 반복 (생일 등)
let yearlyRule = EKRecurrenceRule(
    recurrenceWith: .yearly,
    interval: 1,
    end: nil
)

// 매년 특정 월의 특정 날짜 (예: 3월 15일)
let marchRule = EKRecurrenceRule(
    recurrenceWith: .yearly,
    interval: 1,
    daysOfTheWeek: nil,
    daysOfTheMonth: [15],
    monthsOfTheYear: [3],
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: nil,
    end: nil
)
