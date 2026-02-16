import EventKit

extension CalendarManager {
    func fetchReminderCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .reminder)
    }
    
    var defaultReminderCalendar: EKCalendar? {
        eventStore.defaultCalendarForNewReminders()
    }
}
