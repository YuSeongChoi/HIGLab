import EventKit

extension ReminderManager {
    func fetchCompletedReminders(
        from startDate: Date,
        to endDate: Date
    ) async -> [EKReminder] {
        let predicate = eventStore.predicateForCompletedReminders(
            withCompletionDateStarting: startDate,
            ending: endDate,
            calendars: nil
        )
        
        return await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }
}
