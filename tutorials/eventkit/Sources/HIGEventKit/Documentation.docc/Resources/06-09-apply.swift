import EventKit

extension CalendarManager {
    func createRecurringEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        recurrenceRule: EKRecurrenceRule
    ) throws -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // 반복 규칙 적용
        event.addRecurrenceRule(recurrenceRule)
        
        try eventStore.save(event, span: .thisEvent, commit: true)
        return event
    }
}
