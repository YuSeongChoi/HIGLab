import EventKit
import Combine

class CalendarManager {
    static let shared = CalendarManager()
    
    let eventStore = EKEventStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    let refreshSubject = PassthroughSubject<Void, Never>()
    
    private init() {
        NotificationCenter.default
            .publisher(for: .EKEventStoreChanged, object: eventStore)
            .sink { [weak self] _ in
                self?.handleStoreChanged()
            }
            .store(in: &cancellables)
    }
    
    private func handleStoreChanged() {
        // 외부에 변경 알림
        refreshSubject.send()
    }
}
