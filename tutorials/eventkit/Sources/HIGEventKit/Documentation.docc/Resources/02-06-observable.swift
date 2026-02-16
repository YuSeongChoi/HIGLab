import EventKit
import Combine

@MainActor
class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    
    let eventStore = EKEventStore()
    
    @Published var calendars: [EKCalendar] = []
    @Published var events: [EKEvent] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        NotificationCenter.default
            .publisher(for: .EKEventStoreChanged, object: eventStore)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }
    
    func refresh() {
        calendars = eventStore.calendars(for: .event)
    }
}
