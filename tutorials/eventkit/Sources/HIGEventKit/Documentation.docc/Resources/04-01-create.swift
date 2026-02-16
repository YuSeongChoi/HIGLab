import EventKit

extension CalendarManager {
    func createEvent() -> EKEvent {
        EKEvent(eventStore: eventStore)
    }
}
