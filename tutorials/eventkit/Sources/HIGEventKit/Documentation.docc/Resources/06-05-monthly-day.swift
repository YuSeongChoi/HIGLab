import EventKit

// 매월 첫 번째 월요일
let firstMonday = EKRecurrenceDayOfWeek(.monday, weekNumber: 1)

let firstMondayRule = EKRecurrenceRule(
    recurrenceWith: .monthly,
    interval: 1,
    daysOfTheWeek: [firstMonday],
    daysOfTheMonth: nil,
    monthsOfTheYear: nil,
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: nil,
    end: nil
)

// 매월 마지막 금요일
let lastFriday = EKRecurrenceDayOfWeek(.friday, weekNumber: -1)
