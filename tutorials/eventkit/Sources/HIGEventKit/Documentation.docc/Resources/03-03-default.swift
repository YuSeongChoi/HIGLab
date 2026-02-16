import EventKit

extension CalendarManager {
    var defaultCalendar: EKCalendar? {
        eventStore.defaultCalendarForNewEvents
    }
    
    func fetchCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }
}
