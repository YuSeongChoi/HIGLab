import EventKit

extension CalendarManager {
    func updateAndSaveEvent(
        _ event: EKEvent,
        title: String?,
        location: String?
    ) throws {
        if let title = title {
            event.title = title
        }
        if let location = location {
            event.location = location
        }
        
        try eventStore.save(event, span: .thisEvent, commit: true)
    }
}
