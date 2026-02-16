import EventKit
import Combine

@MainActor
class CalendarManager: ObservableObject {
    let eventStore = EKEventStore()
    
    @Published var needsRefresh = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default
            .publisher(for: .EKEventStoreChanged, object: eventStore)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsRefresh = true
            }
            .store(in: &cancellables)
    }
}
