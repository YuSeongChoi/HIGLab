import EventKit

extension CalendarManager {
    func updateRecurringEvent(
        _ event: EKEvent,
        title: String,
        applyToFuture: Bool
    ) throws {
        event.title = title
        
        let span: EKSpan = applyToFuture ? .futureEvents : .thisEvent
        try eventStore.save(event, span: span, commit: true)
    }
}
