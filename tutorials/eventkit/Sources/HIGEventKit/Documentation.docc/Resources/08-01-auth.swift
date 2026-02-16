import EventKit

extension CalendarManager {
    var reminderAuthorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .reminder)
    }
    
    func requestReminderAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToReminders()
    }
}
