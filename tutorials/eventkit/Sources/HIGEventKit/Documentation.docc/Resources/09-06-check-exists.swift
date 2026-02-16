import EventKit

extension CalendarManager {
    func eventExists(withIdentifier id: String) -> Bool {
        eventStore.event(withIdentifier: id) != nil
    }
    
    func validateStoredEvents(identifiers: [String]) -> [String] {
        identifiers.filter { eventExists(withIdentifier: $0) }
    }
}
