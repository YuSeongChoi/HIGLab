import SwiftUI
import EventKit
import EventKitUI

struct CalendarChooserWrapper: UIViewControllerRepresentable {
    let eventStore: EKEventStore
    let entityType: EKEntityType
    @Binding var selectedCalendars: Set<EKCalendar>
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let chooser = EKCalendarChooser(
            selectionStyle: .multiple,
            displayStyle: .allCalendars,
            entityType: entityType,
            eventStore: eventStore
        )
        chooser.selectedCalendars = selectedCalendars
        chooser.delegate = context.coordinator
        
        return UINavigationController(rootViewController: chooser)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedCalendars: $selectedCalendars)
    }
    
    class Coordinator: NSObject, EKCalendarChooserDelegate {
        @Binding var selectedCalendars: Set<EKCalendar>
        
        init(selectedCalendars: Binding<Set<EKCalendar>>) {
            _selectedCalendars = selectedCalendars
        }
        
        func calendarChooserSelectionDidChange(_ calendarChooser: EKCalendarChooser) {
            selectedCalendars = calendarChooser.selectedCalendars
        }
    }
}
