import EventKit

class CalendarManager {
    static let shared = CalendarManager()
    
    let eventStore = EKEventStore()
    
    private init() {}
}
