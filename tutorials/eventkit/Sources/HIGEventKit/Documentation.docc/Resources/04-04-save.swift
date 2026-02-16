import EventKit

extension CalendarManager {
    func saveEvent(_ event: EKEvent) throws {
        try eventStore.save(event, span: .thisEvent, commit: true)
    }
}
