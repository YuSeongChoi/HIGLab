import EventKit

extension CalendarManager {
    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date
    ) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        return event
    }
}
