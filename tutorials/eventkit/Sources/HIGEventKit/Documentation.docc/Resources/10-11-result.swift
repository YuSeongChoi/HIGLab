import SwiftUI
import EventKit
import EventKitUI

struct CalendarChooserWrapper: UIViewControllerRepresentable {
    let eventStore: EKEventStore
    @Binding var selectedCalendars: Set<EKCalendar>
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let chooser = EKCalendarChooser(
            selectionStyle: .multiple,
            displayStyle: .allCalendars,
            entityType: .event,
            eventStore: eventStore
        )
        chooser.selectedCalendars = selectedCalendars
        chooser.delegate = context.coordinator
        chooser.showsDoneButton = true
        chooser.showsCancelButton = true
        
        return UINavigationController(rootViewController: chooser)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedCalendars: $selectedCalendars, isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, EKCalendarChooserDelegate {
        @Binding var selectedCalendars: Set<EKCalendar>
        @Binding var isPresented: Bool
        
        init(selectedCalendars: Binding<Set<EKCalendar>>, isPresented: Binding<Bool>) {
            _selectedCalendars = selectedCalendars
            _isPresented = isPresented
        }
        
        func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
            selectedCalendars = calendarChooser.selectedCalendars
            isPresented = false
        }
        
        func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
            isPresented = false
        }
    }
}
