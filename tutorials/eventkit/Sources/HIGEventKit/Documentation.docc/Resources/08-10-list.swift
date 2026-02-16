import SwiftUI
import EventKit

struct ReminderListView: View {
    @State private var reminders: [EKReminder] = []
    let reminderManager: ReminderManager
    
    var body: some View {
        List(reminders, id: \.calendarItemIdentifier) { reminder in
            HStack {
                Button {
                    toggleComplete(reminder)
                } label: {
                    Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.plain)
                
                Text(reminder.title)
                    .strikethrough(reminder.isCompleted)
            }
        }
        .task {
            reminders = await reminderManager.fetchIncompleteReminders()
        }
    }
    
    private func toggleComplete(_ reminder: EKReminder) {
        try? reminderManager.completeReminder(reminder)
    }
}
