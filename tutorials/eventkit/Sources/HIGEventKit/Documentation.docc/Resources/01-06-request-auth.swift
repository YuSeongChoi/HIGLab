import EventKit

class CalendarManager {
    let eventStore = EKEventStore()
    
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToEvents()
    }
}
