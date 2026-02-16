import EventKit

extension CalendarManager {
    func fetchCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }
}
