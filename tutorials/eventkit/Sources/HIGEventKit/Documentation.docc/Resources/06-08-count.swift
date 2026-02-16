import EventKit

// 10회 반복 후 종료
let ruleWithCount = EKRecurrenceRule(
    recurrenceWith: .weekly,
    interval: 1,
    end: EKRecurrenceEnd(occurrenceCount: 10)
)
