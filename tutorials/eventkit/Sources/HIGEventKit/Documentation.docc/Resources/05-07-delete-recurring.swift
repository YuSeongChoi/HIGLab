import EventKit

extension CalendarManager {
    func deleteRecurringEvent(
        _ event: EKEvent,
        deleteAllFuture: Bool
    ) throws {
        let span: EKSpan = deleteAllFuture ? .futureEvents : .thisEvent
        try eventStore.remove(event, span: span, commit: true)
    }
}
