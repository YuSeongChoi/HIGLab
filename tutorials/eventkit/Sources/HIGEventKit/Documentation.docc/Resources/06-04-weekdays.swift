import EventKit

// 매주 월, 수, 금요일
let weekdays: [EKRecurrenceDayOfWeek] = [
    EKRecurrenceDayOfWeek(.monday),
    EKRecurrenceDayOfWeek(.wednesday),
    EKRecurrenceDayOfWeek(.friday)
]

let mwfRule = EKRecurrenceRule(
    recurrenceWith: .weekly,
    interval: 1,
    daysOfTheWeek: weekdays,
    daysOfTheMonth: nil,
    monthsOfTheYear: nil,
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: nil,
    end: nil
)
