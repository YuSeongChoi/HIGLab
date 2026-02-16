import EventKit

// 2025년 12월 31일까지 반복
let endDate = Calendar.current.date(
    from: DateComponents(year: 2025, month: 12, day: 31)
)!

let ruleWithEndDate = EKRecurrenceRule(
    recurrenceWith: .weekly,
    interval: 1,
    end: EKRecurrenceEnd(end: endDate)
)
