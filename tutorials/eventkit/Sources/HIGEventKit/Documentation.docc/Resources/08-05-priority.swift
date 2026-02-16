import EventKit

extension ReminderManager {
    // 우선순위: 0 = 없음, 1-4 = 높음, 5 = 중간, 6-9 = 낮음
    
    func createReminder(
        title: String,
        dueDate: Date?,
        priority: Int = 0
    ) -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        reminder.priority = priority
        
        if let dueDate = dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        }
        
        return reminder
    }
}
