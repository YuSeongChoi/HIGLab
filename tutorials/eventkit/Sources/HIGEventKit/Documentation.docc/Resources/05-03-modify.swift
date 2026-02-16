import EventKit

extension CalendarManager {
    func updateEvent(_ event: EKEvent, title: String?, location: String?) {
        if let title = title {
            event.title = title
        }
        if let location = location {
            event.location = location
        }
    }
}
