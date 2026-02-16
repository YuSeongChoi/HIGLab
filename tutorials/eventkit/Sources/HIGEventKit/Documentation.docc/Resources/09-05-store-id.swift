import EventKit

extension CalendarManager {
    func saveEventId(_ event: EKEvent) {
        UserDefaults.standard.set(
            event.eventIdentifier,
            forKey: "lastCreatedEvent"
        )
    }
    
    func loadSavedEvent() -> EKEvent? {
        guard let id = UserDefaults.standard.string(forKey: "lastCreatedEvent") else {
            return nil
        }
        return eventStore.event(withIdentifier: id)
    }
}
