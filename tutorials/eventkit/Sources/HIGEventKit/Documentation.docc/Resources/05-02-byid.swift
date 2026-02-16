import EventKit

extension CalendarManager {
    func fetchEvent(withIdentifier identifier: String) -> EKEvent? {
        eventStore.event(withIdentifier: identifier)
    }
    
    func fetchCalendarItem(withIdentifier identifier: String) -> EKCalendarItem? {
        eventStore.calendarItem(withIdentifier: identifier)
    }
}
