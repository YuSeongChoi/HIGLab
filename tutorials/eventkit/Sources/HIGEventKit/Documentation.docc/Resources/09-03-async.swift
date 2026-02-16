import EventKit

@MainActor
class CalendarManager: ObservableObject {
    let eventStore = EKEventStore()
    
    @Published var events: [EKEvent] = []
    
    func fetchEvents(from start: Date, to end: Date) async {
        let predicate = eventStore.predicateForEvents(
            withStart: start,
            end: end,
            calendars: nil
        )
        
        // Main actor에서 실행되므로 안전하게 할당
        events = eventStore.events(matching: predicate)
    }
}
