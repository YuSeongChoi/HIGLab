import EventKit

class CalendarManager {
    let eventStore = EKEventStore()
    
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToEvents()
    }
    
    func checkAndRequestAccess() async -> Bool {
        switch authorizationStatus {
        case .authorized, .fullAccess:
            return true
        case .notDetermined:
            do {
                return try await requestAccess()
            } catch {
                return false
            }
        case .denied, .restricted, .writeOnly:
            return false
        @unknown default:
            return false
        }
    }
}
