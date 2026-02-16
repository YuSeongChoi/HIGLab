import EventKit
import Combine

@MainActor
class CalendarManager: ObservableObject {
    let eventStore = EKEventStore()
    
    @Published var events: [EKEvent] = []
    @Published var calendars: [EKCalendar] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
        // 이벤트도 다시 불러오기
        fetchTodayEvents()
    }
    
    private func fetchTodayEvents() {
        let now = Date()
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: endOfDay,
            calendars: nil
        )
        
        events = eventStore.events(matching: predicate)
    }
}
