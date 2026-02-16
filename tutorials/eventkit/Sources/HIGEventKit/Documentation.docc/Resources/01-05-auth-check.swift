import EventKit

class CalendarManager {
    let eventStore = EKEventStore()
    
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }
}
