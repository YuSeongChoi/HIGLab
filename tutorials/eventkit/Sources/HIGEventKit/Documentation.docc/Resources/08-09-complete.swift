import EventKit

extension ReminderManager {
    func completeReminder(_ reminder: EKReminder) throws {
        reminder.isCompleted = true
        reminder.completionDate = Date()
        try eventStore.save(reminder, commit: true)
    }
    
    func uncompleteReminder(_ reminder: EKReminder) throws {
        reminder.isCompleted = false
        reminder.completionDate = nil
        try eventStore.save(reminder, commit: true)
    }
}
