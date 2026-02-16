import EventKit

extension ReminderManager {
    func saveReminder(_ reminder: EKReminder) throws {
        try eventStore.save(reminder, commit: true)
    }
    
    func createAndSaveReminder(
        title: String,
        dueDate: Date?
    ) throws -> EKReminder {
        let reminder = createReminder(title: title, dueDate: dueDate, priority: 0)
        try saveReminder(reminder)
        return reminder
    }
}
