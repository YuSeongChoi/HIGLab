import EventKit

extension CalendarManager {
    func calendarsBySource() -> [(EKSource, [EKCalendar])] {
        let calendars = eventStore.calendars(for: .event)
        
        let grouped = Dictionary(grouping: calendars) { $0.source }
        
        return grouped.map { ($0.key, $0.value) }
            .sorted { $0.0.title < $1.0.title }
    }
}
